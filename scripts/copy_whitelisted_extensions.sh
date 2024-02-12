#!/usr/bin/env bash

# Check the number of arguments provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 source-directory target-directory"
    exit 1
fi

# Assign the source and target directories to variables
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

# Define an array of file extensions
declare -a EXTENSIONS=(
    ".c" ".h"
    ".cpp" ".cxx" ".cc" ".C" ".c++"
    ".hpp" ".hxx" ".hh" ".H" ".h++"
    ".go"
    ".java"
    ".js" ".mjs" ".cjs"
    ".kt" ".kts"
    ".php" ".phtml" ".php3" ".php4" ".php5" ".php7"
    ".py"
    ".rb"
    ".rs"
    ".scala" ".sc"
    ".swift"
    ".ts" ".tsx"
)

# Copy files with the defined extensions
for ext in "${EXTENSIONS[@]}"; do
    # Use find to handle filenames with spaces and to be more efficient on large directories
    find "$SOURCE_DIR" -maxdepth 1 -type f -name "*$ext" -exec cp {} "$TARGET_DIR" \;
done

echo "Files copied from $SOURCE_DIR to $TARGET_DIR."