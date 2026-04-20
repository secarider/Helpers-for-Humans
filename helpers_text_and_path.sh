#!/usr/bin/env bash
#
# TEXT AND PATH HELPERS

# ========================================================
# MARKER: CANONICAL PATH NORMALIZER
# ========================================================
# PURPOSE:
# - Collapse repeated leading "./" segments
# - Create one stable path style for comparisons / ledger lookups
#
# EXAMPLES:
# - ./file.mkv     -> file.mkv
# - ././file.mkv   -> file.mkv
#
# USAGE:
#   clean="$(canonical_factory_path "$raw_path")"
# ========================================================
canonical_factory_path() {
    local p="$1"

    while [[ "$p" == ./* ]]; do
        p="${p#./}"
    done

    printf '%s\n' "$p"
}

# =========================
# #MARKER: HMS DISPLAY HELPER
# =========================
# PURPOSE:
# - Convert decimal seconds into HH:MM:SS.mmm for friendly display
#
# EXAMPLE:
# - 2592.616 -> 00:43:12.616
# =========================
format_seconds_hms() {
	local total="${1:-0}"

	awk -v t="$total" 'BEGIN {
		if (t < 0) t = 0

		h = int(t / 3600)
		m = int((t - (h * 3600)) / 60)
		s = t - (h * 3600) - (m * 60)

		printf "%02d:%02d:%06.3f", h, m, s
	}'
}

