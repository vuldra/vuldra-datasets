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

# Copy files that are less than the specified maximum file size
find "$SOURCE_DIR" -type f -size -"${MAX_SIZE}"k -exec cp {} "$TARGET_DIR" \;

echo "Copy complete."
