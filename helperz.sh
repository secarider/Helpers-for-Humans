#!/usr/bin/env bash
#
#          this is just storage it is NOT an actual script
#                 GLOBAL HELPER LIBRARY
# ========================================================
# MARKER: GLOBAL HELPER LIBRARY
# ========================================================
#
# PURPOSE:
# --------
# Shared helper storage for menu-driven Bash tools.
#
# DESIGN GOALS:
# -------------
# - ten-key friendly
# - consistent prompt formatting
# - safe read -r usage
# - copy/paste friendly
# - low dependency
#
# LAYOUT:
# -------
# 1) INPUT AND EXIT
# 2) TEXT AND PATH
# 3) CSV AND SIZES
# 4) COLOR SYSTEM / THEMES   (recommended to split into its own file later)
# ========================================================


# ========================================================
# MARKER: GLOBAL HELPER LIBRARY / INPUT AND EXIT
# ========================================================
#
# INCLUDED:
# ---------
# - is_exit_token
# - ask_yes_no
# - prompt_read
# - prompt_menu_choice
# - prompt_read_stderr
# - prompt_menu_choice_stderr
#
# HOUSE NOTES:
# ------------
# - "0." is treated as a ten-key friendly back / exit token
# - q / Q are also accepted
# - prompts remain human-facing and color-friendly
# - STDERR prompt variants exist for command-substitution helpers:
#       value="$(some_helper)"
#   so human prompts stay visible while machine return values stay clean
# ========================================================

# ========================================================
# MARKER: FACTORY EXIT TOKEN / TEN-KEY FRIENDLY
# ========================================================
# PURPOSE:
# - Provide one universal cancel / return token style
# - Support both classic keyboard use and ten-key use
#
# ACCEPTS:
# - 0
# - 0.
# - q
# - Q
#
# USAGE:
#   if is_exit_token "$choice"; then
#       return 0
#   fi
# ========================================================
is_exit_token() {
    local v="${1:-}"
    [[ "$v" == "0" || "$v" == "0." || "$v" == "q" || "$v" == "Q" ]]
}

# ========================================================
# MARKER: ASK YES NO
# ========================================================
# PURPOSE:
# - Standard yes/no prompt with ten-key friendly support
#
# YES VALUES:
# - y
# - yes
# - 1
#
# NO VALUES:
# - n
# - no
# - 2
# - blank
#
# RETURN:
# - 0 for YES
# - 1 for NO / invalid / blank
#
# USAGE:
#   if ask_yes_no " = = > Proceed? (y/n or 1/2): "; then
#       ...
#   fi
# ========================================================
ask_yes_no() {
    local prompt="$1"
    local ans

    echo -e "${YELLOW}${prompt}${NC}"
    read -r ans

    ans="${ans,,}"
    ans="${ans//[[:space:]]/}"

    case "${ans:-2}" in
        y|yes|1) return 0 ;;
        n|no|2|"") return 1 ;;
        *) return 1 ;;
    esac
}

# ========================================================
# MARKER: GENERIC PROMPT READ HELPER
# ========================================================
# PURPOSE:
# - Standardize one-line user input prompts
# - Keep prompt formatting consistent across scripts
#
# USAGE:
#   prompt_read " = = > Enter Name: " user_name
#
# NOTES:
# - prompt text is caller-controlled
# - helper writes directly into the named variable
# - the trailing reset echo is intentional house style
# ========================================================
prompt_read() {
    local prompt="$1"
    local __var_name="$2"
    local __input

    echo -ne "${YELLOW}${prompt}"
    read -r __input
    echo -e "${NC}"

    printf -v "$__var_name" '%s' "$__input"
}

# ========================================================
# MARKER: MENU CHOICE HELPER
# ========================================================
# PURPOSE:
# - Read menu selections consistently
# - Normalize lowercase
# - Strip whitespace
#
# USAGE:
#   prompt_menu_choice " = = > Choose [1-3 | 0=return]: " choice
#
# NOTES:
# - intended for normal interactive menus
# - use the STDERR variant inside command-substitution helpers
# ========================================================
prompt_menu_choice() {
    local prompt="$1"
    local __var_name="$2"
    local __input

    echo -ne "${YELLOW}${prompt}"
    read -r __input
    echo -e "${NC}"

    __input="${__input//[[:space:]]/}"
    __input="${__input,,}"

    printf -v "$__var_name" '%s' "$__input"
}

# ========================================================
# MARKER: STDERR PROMPT READ HELPER
# ========================================================
# PURPOSE:
# - Standardize prompts inside command-substitution helpers
# - Keep human prompts visible while machine return values stay on STDOUT
#
# USAGE:
#   prompt_read_stderr " = = > Enter Value: " var_name
#
# EXAMPLE:
#   some_value="$(some_helper)"
#
# NOTES:
# - use this when the surrounding helper must print a return value to STDOUT
# - prompt text goes to STDERR so it does not get swallowed by command substitution
# ========================================================
prompt_read_stderr() {
    local prompt="$1"
    local __var_name="$2"
    local __input

    echo -ne "${YELLOW}${prompt}" >&2
    read -r __input
    echo -e "${NC}" >&2

    printf -v "$__var_name" '%s' "$__input"
}

# ========================================================
# MARKER: STDERR MENU CHOICE HELPER
# ========================================================
# PURPOSE:
# - Standardize menu-selection prompts inside command-substitution helpers
# - Normalize lowercase
# - Strip whitespace
# - Keep menu text visible while machine return values stay clean
#
# USAGE:
#   prompt_menu_choice_stderr " = = > Choose [1-3 | 0=return]: " choice
#
# EXAMPLE:
#   mode="$(some_helper)"
# ========================================================
prompt_menu_choice_stderr() {
    local prompt="$1"
    local __var_name="$2"
    local __input

    echo -ne "${YELLOW}${prompt}" >&2
    read -r __input
    echo -e "${NC}" >&2

    __input="${__input//[[:space:]]/}"
    __input="${__input,,}"

    printf -v "$__var_name" '%s' "$__input"
}


# ========================================================
# MARKER: GLOBAL HELPER LIBRARY / TEXT AND PATH
# ========================================================
#
# INCLUDED:
# ---------
# - canonical_factory_path
#
# NOTE:
# -----
# The current name is kept here to match your live script,
# but this is a strong candidate for later rename to:
#   canonical_path
# if you want a more public / neutral name.
# ========================================================

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


# ========================================================
# MARKER: GLOBAL HELPER LIBRARY / CSV AND SIZES
# ========================================================
#
# INCLUDED:
# ---------
# - format_bytes_human
# - csv_escape
#
# DESIGN:
# -------
# - human-facing reporting
# - low dependency
# - safe enough for shell-level ledger / csv work
# ========================================================

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
#
# NOTE:
# -----
# This is ideal for simple shell-generated CSV rows.
# ========================================================
csv_escape() {
    local s="$1"
    s="${s//\"/\"\"}"
    printf '"%s"' "$s"
}


# ========================================================
# MARKER: GLOBAL HELPER LIBRARY / COLOR SYSTEM
# ========================================================
#
# PURPOSE:
# --------
# Shared display palette and theme helpers for Bash tools.
#
# RECOMMENDATION:
# ---------------
# Keep this section in a separate file because it is larger
# and more opinionated than the smaller helper groups above.
#
# SUGGESTED FILE:
#   helpers_colors_and_themes.sh
# ========================================================
