#!/usr/bin/env bash
#
# INPUT AND EXIT HELPERS
# Shared user-input helpers for menu-driven Bash tools.

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

# Safe Pause Function With Color
pause() {
    echo -e "${GR}>->->->-> = = > Review Above Carefully.....${NC}"
    echo -e "${BW}>->->->-> = = > Screen Will Clear When You ${NC}"
    echo -e "${YE}>->->->-> = = > Press Enter To Continue....${NC}"
    read -r _
}

