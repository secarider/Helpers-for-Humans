#!/usr/bin/env bash
#
# MATH AND TIME HELPERS
#
# PURPOSE:
# --------
# - Lightweight math + time formatting utilities
# - Designed for shell workflows (ffmpeg, timing, offsets, etc.)
# - Avoid heavy dependencies beyond awk / bc
#
# DESIGN NOTES:
# -------------
# - Safe for floating point where needed
# - Consistent formatting for human display
# - Copy/paste friendly for scripting use


# ========================================================
# MARKER: FLOAT ADD
# ========================================================
# PURPOSE:
# - Add two floating point numbers safely
#
# USAGE:
#   result="$(fadd 1.5 2.25)"
# ========================================================
fadd() {
    awk -v a="${1:-0}" -v b="${2:-0}" 'BEGIN { printf "%.6f", a + b }'
}


# ========================================================
# MARKER: FLOAT SUBTRACT
# ========================================================
# PURPOSE:
# - Subtract two floating point numbers safely
#
# USAGE:
#   result="$(fsub 5.0 2.25)"
# ========================================================
fsub() {
    awk -v a="${1:-0}" -v b="${2:-0}" 'BEGIN { printf "%.6f", a - b }'
}


# ========================================================
# MARKER: FLOAT MAX ZERO
# ========================================================
# PURPOSE:
# - Prevent negative values (clamp to zero)
#
# USAGE:
#   safe="$(fmax0 "$value")"
# ========================================================
fmax0() {
    awk -v v="${1:-0}" 'BEGIN {
        if (v < 0) printf "0"
        else printf "%.6f", v
    }'
}


# ========================================================
# MARKER: SECONDS TO HH:MM:SS
# ========================================================
# PURPOSE:
# - Convert seconds (float or int) into HH:MM:SS
#
# EXAMPLES:
#   65      -> 00:01:05
#   3661    -> 01:01:01
#
# USAGE:
#   pretty="$(format_seconds_hms "$seconds")"
# ========================================================
format_seconds_hms() {
    local total="${1:-0}"

    awk -v t="$total" 'BEGIN {
        h = int(t / 3600)
        m = int((t % 3600) / 60)
        s = int(t % 60)
        printf "%02d:%02d:%02d", h, m, s
    }'
}
