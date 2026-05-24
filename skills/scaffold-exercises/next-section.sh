#!/bin/bash
# Prints next section number (XX) based on existing XX-* dirs
# Usage: next-section.sh [exercises-dir]
count=$(find "${1:-exercises}" -maxdepth 1 -type d -name '[0-9][0-9]-*' | wc -l)
printf '%02d\n' $((count + 1))
