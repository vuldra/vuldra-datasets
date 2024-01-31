#!/usr/bin/env bash

# Check if exactly three arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_dir> <target_dir>"
    exit 1
fi

# Assign arguments to variables
SOURCE_DIR=$1
TARGET_DIR=$2

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Check if target directory exists, if not create it
if [ ! -d "$TARGET_DIR" ]; then
    echo "Target directory '$TARGET_DIR' does not exist. Creating it now."
    mkdir -p "$TARGET_DIR"
fi

# Function to copy files without an extension and not starting with a dot
copy_files() {
    local parent_dir=$(basename $1) # Get the name of the current directory
    echo $parent_dir
    local file

    # Loop through all files in the current directory
    for file in $1/*; do
      echo $file
        if [[ -d "$file" ]]; then
            # If it's a directory, recurse into it
            copy_files "$file $TARGET_DIR"
        elif [[ -f "$file" && ! "$file" =~ /\.[^/]*$ && ! $(basename "$file") =~ ^\. ]]; then
            # If it's a file without an extension and not starting with a dot, copy it
            local new_name=$(basename "$file").$parent_dir
            cp "$file" "$TARGET_DIR/$new_name"
        fi
    done
}

# Start the recursive copy from the current directory
copy_files "$SOURCE_DIR"

echo "Files have been copied to $TARGET_DIR"
