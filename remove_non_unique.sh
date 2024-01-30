#!/usr/bin/env bash

# Step 1: List all files and Step 2: Extract IDs
declare -A id_count # Associative array to hold the count of each ID

for file in bad_*_*.*; do
    if [[ $file =~ bad_([0-9]+)_ ]]; then
        id=${BASH_REMATCH[1]}
        ((id_count[$id]++)) # Increment the count for this ID
    fi
done

# Step 3 and 4: Identify duplicates and Step 5: Delete files with duplicate IDs
for id in "${!id_count[@]}"; do
    if [[ ${id_count[$id]} -gt 1 ]]; then
        # If the count is greater than 1, it means there are duplicates
        rm -v "bad_${id}"_*.* # Delete all files with this ID
    fi
done