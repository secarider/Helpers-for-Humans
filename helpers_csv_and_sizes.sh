#!/usr/bin/env bash
#
# CSV AND SIZE HELPERS

# ========================================================
# MARKER: HUMAN SIZE DISPLAY HELPER
# ========================================================
# PURPOSE:
# - Convert raw byte counts into friendly KB / MB / GB text
#
# EXAMPLES:
# - 584194734  -> 557.1 MB
# - 1073741824 -> 1.00 GB
#
# USAGE:
#   pretty="$(format_bytes_human "$bytes")"
# ========================================================
format_bytes_human() {
    local bytes="${1:-0}"

    awk -v b="$bytes" 'BEGIN {
        if (b < 1024) {
            printf "%d B", b
        } else if (b < 1048576) {
            printf "%.1f KB", b / 1024
        } else if (b < 1073741824) {
            printf "%.1f MB", b / 1048576
        } else {
            printf "%.2f GB", b / 1073741824
        }
    }'
}

# ========================================================
# MARKER: CSV ESCAPE HELPER
# ========================================================
# PURPOSE:
# - Escape quotes safely for lightweight CSV writing
# - Keep commas and quotes from mangling shell-built ledgers
#
# USAGE:
#   printf '%s\n' "$(csv_escape "$value")"
# ========================================================
csv_escape() {
    local s="$1"
    s="${s//\"/\"\"}"
    printf '"%s"' "$s"
}
