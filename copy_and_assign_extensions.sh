#!/usr/bin/env bash

# Target directory where files will be copied
TARGET_DIR="$HOME/Downloads/vuldra-dataset"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

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
            copy_files "$file"
        elif [[ -f "$file" && ! "$file" =~ /\.[^/]*$ && ! $(basename "$file") =~ ^\. ]]; then
            # If it's a file without an extension and not starting with a dot, copy it
            local new_name=$(basename "$file").$parent_dir
            cp "$file" "$TARGET_DIR/$new_name"
        fi
    done
}

# Start the recursive copy from the current directory
copy_files "."

echo "Files have been copied to $TARGET_DIR"
