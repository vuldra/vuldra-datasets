#!/usr/bin/env bash

# Check if exactly four arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <source_dir> <target_dir> <min_file_size_in_bytes> <max_file_size_in_bytes>"
    exit 1
fi

# Assign arguments to variables
SOURCE_DIR=$1
TARGET_DIR=$2
MIN_SIZE=$3
MAX_SIZE=$4

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

get_file_size_b() {
    echo $(wc -c $1 | awk '{print $1}')
}

copy_files_if_in_size_range() {
    local good_file="$1"
    local bad_file="${good_file/good_/bad_}"

    # Get file sizes in bytes
    local good_file_size_b=$(get_file_size_b "$good_file")
    local bad_file_size_b=$(get_file_size_b "$bad_file")

    # Check if both good and bad files are within the size range
    if [ "$good_file_size_b" -ge "$MIN_SIZE" ] && [ "$good_file_size_b" -le "$MAX_SIZE" ] &&
       [ "$bad_file_size_b" -ge "$MIN_SIZE" ] && [ "$bad_file_size_b" -le "$MAX_SIZE" ]; then
        cp "$good_file" "$TARGET_DIR"
        cp "$bad_file" "$TARGET_DIR"
        echo "Copied $good_file and $bad_file to $TARGET_DIR"
    else
        echo "File $good_file or $bad_file is not within the size range ($MIN_SIZE - $MAX_SIZE Bytes)"
    fi
}

# Find all good files that are within the specified size range
find "$SOURCE_DIR" -type f -name "good_*" | while read good_file; do
    if [ -f "${good_file/good_/bad_}" ]; then
        copy_files_if_in_size_range "$good_file"
    else
        echo "No corresponding bad file for $good_file"
    fi
done

echo "Copy complete."
