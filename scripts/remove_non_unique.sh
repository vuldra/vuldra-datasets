#!/usr/bin/env bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 SOURCE_DIRECTORY"
    exit 1
fi

SOURCE_DIRECTORY=$1

# Ensure the SOURCE_DIRECTORY has a trailing slash
SOURCE_DIRECTORY="${SOURCE_DIRECTORY%/}/"

# Check if the SOURCE_DIRECTORY exists and is a directory
if [ ! -d "$SOURCE_DIRECTORY" ]; then
    echo "Error: SOURCE_DIRECTORY '${SOURCE_DIRECTORY}' does not exist or is not a directory."
    exit 1
fi

declare -A id_count # Associative array to hold the count of each ID
for prefix in bad good; do
    for file in "${SOURCE_DIRECTORY}${prefix}"_*_*.*; do
        if [[ $file =~ (${prefix}_[0-9]+)_ ]]; then
            id=${BASH_REMATCH[1]}
            ((id_count[$id]++)) # Increment the count for this ID
        fi
    done
done

for id in "${!id_count[@]}"; do
    if [[ ${id_count[$id]} -gt 1 ]]; then
        # If the count is greater than 1, it means there are duplicates
        echo "Removing duplicates for ID: $id"
        rm -v "${SOURCE_DIRECTORY}"{bad,good}"_${id}"_*.* # Delete all files with this ID
    fi
done