#!/usr/bin/env bash
# Usage: ghostty-to-vhs-theme.sh <ghostty-theme.conf> "<theme name>" > theme.json
set -e

awk -v name="$2" '
/^background/ { bg = $3 }
/^foreground/ { fg = $3 }
/^cursor-color/ { cur = $3 }
/^selection-background/ { sel = $3 }
/^palette/ { split($3, a, "="); p[a[1]] = a[2] }
END {
  split("black red green yellow blue magenta cyan white", n, " ")
  printf "{\n  \"name\": \"%s\",\n", name
  for (i = 0; i < 8; i++) printf "  \"%s\": \"%s\",\n", n[i + 1], p[i]
  for (i = 0; i < 8; i++) printf "  \"bright%s\": \"%s\",\n", toupper(substr(n[i + 1], 1, 1)) substr(n[i + 1], 2), p[i + 8]
  printf "  \"background\": \"%s\",\n  \"foreground\": \"%s\",\n  \"selection\": \"%s\",\n  \"cursor\": \"%s\"\n}\n", bg, fg, sel, cur
}' "$1"
