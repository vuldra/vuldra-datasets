#!/usr/bin/env bash

# Check if exactly three arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_dir> <target_dir> <max_file_size_in_kbytes>"
    exit 1
fi

# Assign arguments to variables
SOURCE_DIR=$1
TARGET_DIR=$2
MAX_SIZE=$3

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Check if target directory exists, if not create it
if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory '$TARGET_DIR' does not exist. Creating it now."
    mkdir -p "$TARGET_DIR"
fi

copy_files_if_good_is_small() {
    local good_file="$1"
    local bad_file="${good_file/good_/bad_}"

    if [ -f "$bad_file" ]; then
        # Good file is smaller than MAX_SIZE, so copy both good and bad files
        cp "$good_file" "$TARGET_DIR"
        cp "$bad_file" "$TARGET_DIR"
        echo "Copied $good_file and $bad_file to $TARGET_DIR"
    else
        echo "No corresponding bad file for $good_file"
    fi
}

# Find all good files that are smaller than the specified maximum file size
find "$SOURCE_DIR" -type f -name "good_*" -size -${MAX_SIZE} | while read good_file; do
    copy_files_if_good_is_small "$good_file"
done

echo "Copy complete."
