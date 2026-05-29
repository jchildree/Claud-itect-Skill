#!/usr/bin/env bash
# Prints the next available ADR number, zero-padded to 4 digits.
# Usage: bash next-adr-number.sh [docs/adr]
count=$(find "${1:-docs/adr}" -name 'ADR-[0-9]*.md' 2>/dev/null | wc -l)
printf '%04d\n' $((count + 1))
