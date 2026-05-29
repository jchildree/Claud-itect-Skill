#!/usr/bin/env bash
# Print all vault .md files with their outbound [[wikilinks]]
# Usage: ./wiki-graph.sh <vault-path>
VAULT="${1:-.}"
find "$VAULT" -name "*.md" | sort | while read -r f; do
  name=$(basename "$f" .md)
  links=$(grep -oP '\[\[([^\]]+)\]\]' "$f" 2>/dev/null | sed 's/\[\[//;s/\]\]//' | sort -u | tr '\n' ', ' | sed 's/,$//')
  if [ -n "$links" ]; then
    echo "$name -> $links"
  else
    echo "$name -> (no links)"
  fi
done
