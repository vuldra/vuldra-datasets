# Vuldra Evaluation Dataset

## Datasets

All vuldra datasets are based on the [CrossVul dataset](https://zenodo.org/records/4734050)
by [Nikitopoulos et al.](https://dl.acm.org/doi/10.1145/3468264.3473122) The vuldra datasets are a minimized versions of
the CrossVul dataset, that only contain good/bad sample pairs that could be linked commits originating in open source
projects that patched vulnerabilities within a single file. The datasets have been generated using the provided bash
scripts and are divided by size of individual files.

| Dataset                    | Description                          | Good samples | Bad samples | Total disk size |
|----------------------------|--------------------------------------|--------------|-------------|-----------------|
| [data_small](data_small)   | Each good file <= 100 byte file size | 4            | 4           | 12 KB           |
| [data_medium](data_medium) | Each good file <= 1 KB file size     | 31           | 31          | 56 KB           |
| [data_large](data_large)   | Each good file <= 2.8 KB file size   | 154          | 154         | 516 KB          |
| [data_xl](data_xl)         | Each good file <= 10 KB file size    | 692          | 692         | 7.3 MB          |

## Usage of scripts

1. `copy_and_assign_extensions.sh <SOURCE_DIR> <DESTINATION_DIR>`- Copies all files from the source
   directory to the destination directory and assigns the file extension based on directory name that the file exists
   within the CrossVul dataset.
2. `remove_non_unique.sh <DIR>` - Removes all files which do not have a unique commit number withing the good/bad
   samples.
3. `copy_whitelisted_extensions.sh <SOURCE_DIR> <DESTINATION_DIR>` - Copies all files matching extensions
   supported by [Semgrep](https://semgrep.dev/docs/supported-languages/)
   or [Snyk](https://docs.snyk.io/scan-using-snyk/supported-languages-and-frameworks) from the source directory to the
   destination directory.
4. `copy_max_filesize.sh <SOURCE_DIR> <DESTINATION_DIR> <MAX_FILESIZE>` - Copies all files from the source directory to
   the destination directory that are smaller or equal to the specified maximum file size. Provide the maximum file size
   with a suffix _c = Bytes_, _k = KB_, _M = MB_ which is then used by
   the [find](https://man7.org/linux/man-pages/man1/find.1.html) command.

## Other Commands

- `ls -1 good* | wc -l && ls -1 bad* | wc -l` - Count how many `good`/`bad` samples are in the current directory
- `find . -type f | sed -E 's/.*\.([^.]+)$/\1/' | sort | uniq -c` - Count file extensions in current directory