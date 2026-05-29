#!/usr/bin/env bash
# Detects the package manager in use by checking lockfiles.
# Prints: npm | yarn | pnpm | unknown
if [ -f yarn.lock ]; then echo yarn
elif [ -f pnpm-lock.yaml ]; then echo pnpm
elif [ -f package-lock.json ]; then echo npm
else echo unknown
fi
