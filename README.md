# Vuldra Evaluation Dataset
## Commands
- `find . -type f | sed -E 's/.*\.([^.]+)$/\1/' | sort | uniq -c` - Count file extensions in current directory
- `ls -1 good* | wc -l && ls -1 bad* | wc -l` - Count how many `good`/`bad` samples are in the current directory