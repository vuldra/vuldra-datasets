// +build !windows

package createconfig

import "syscall"

// Abort will terminate & sends SIGTERM to process
func Abort(i ...int) {
	pgid, err := syscall.Getpgid(syscall.Getpid())
	if err != nil {
		Exit(err.Error())
	}

	// nolint:errcheck
	syscall.Kill(-pgid, syscall.SIGTERM)
}
