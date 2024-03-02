# Vuldra Evaluation Datasets

This repository contains datasets of vulnerable source code and the corresponding patches. The datasets are used to
evaluate the performance of vuldra and could also be used in other research projects.

## Datasets

All Vuldra datasets are based on the [CrossVul dataset](https://zenodo.org/records/4734050)
by [Nikitopoulos et al.](https://dl.acm.org/doi/10.1145/3468264.3473122). The Vuldra datasets are minimised versions of
the CrossVul dataset, containing only good/bad sample pairs that can be associated with commits from open source
projects that have patched vulnerabilities in a single file.

The datasets were generated using the provided bash scripts and are sorted by the size of each file. Like in the
CrossVul dataset, files labeled as `good_*` are the patched version of files labeled as `bad_*`. All datasets have a
balanced number of good and bad samples. Files below 100 Bytes have been excluded, since they do not contain enough
information to be useful for the scanning with a LLM.

| Dataset                                 | Individual file size    | Good samples | Bad samples | Total disk size | Should stay below OpenAI TPM limit |
|-----------------------------------------|-------------------------|--------------|-------------|-----------------|------------------------------------|
| [crossvul small](data/crossvul/small)   | 100 B <= size <= 1 KB   | 19           | 19          | 25 KB           | < 150K TPM                         |
| [crossvul medium](data/crossvul/medium) | 100 B <= size <= 2 KB   | 83           | 83          | 209 KB          | < 150K TPM                         |
| [crossvul large](data/crossvul/large)   | 100 B <= size <= 3.5 KB | 196          | 196         | 823 KB          | < 600K TPM                         |

## Usage of scripts

Scripts require Bash version 4.0 or higher.

1. `copy_and_assign_extensions.sh <SOURCE_DIR> <DESTINATION_DIR>`- Copies all files from the source
   directory to the destination directory and assigns the file extension based on directory name that the file exists
   within the CrossVul dataset.
2. `remove_non_unique.sh <DIR>` - Removes all files which do not have a unique commit number withing the good/bad
   samples.
3. `copy_whitelisted_extensions.sh <SOURCE_DIR> <DESTINATION_DIR>` - Copies all files matching extensions
   supported by [Semgrep](https://semgrep.dev/docs/supported-languages/)
   or [Snyk](https://docs.snyk.io/scan-using-snyk/supported-languages-and-frameworks) from the source directory to the
   destination directory.
4. `copy_min_max_filesize.sh <SOURCE_DIR> <DESTINATION_DIR> <MIN_FILESIZE_B> <MAX_FILESIZE_B>` - Copies all sample
   pairs, that are between min and max files size specified in Bytes.

## Other Commands

- `ls -1 good* | wc -l && ls -1 bad* | wc -l` - Count how many `good`/`bad` samples are in the current directory
- `find . -type f | sed -E 's/.*\.([^.]+)$/\1/' | sort | uniq -c` - Count file extensions in current directory