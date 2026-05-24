#!/bin/bash
# Prints next available ADR number, zero-padded to 3 digits
count=$(find "${1:-docs/adr}" -name 'ADR-[0-9]*.md' | wc -l)
printf '%03d\n' $((count + 1))
