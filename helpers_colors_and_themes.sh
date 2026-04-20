# ===== COLOR SYSTEM / TWISTED THEME ENGINE ===================================
# PURPOSE:
# Centralize all standard display colors in one place so the script can:
#   1) keep a stable default color layout
#   2) remap the normal display palette on demand
#   3) preserve warning semantics no matter what theme is active
#
# DESIGN:
# - STANDARD DISPLAY COLORS:
#     RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BWHITE NC
#   These are cosmetic / display-facing colors and may be remapped by twisted().
#
# - FIXED SEMANTIC WARNING COLORS:
#     RE REB YE YEB GR BW
#   These are reserved for true meaning-based warnings / verdicts and must NOT
#   be remapped by twisted(). Use these for:
#     GR = SAFE / PASS / OK
#     YE = CAUTION / NOTICE / WARNING
#    YEB = Yellow Blinking
#     RE = RISK / FAIL / DANGER / DESTRUCTIVE
#    REB = Red Blinking
#     BW = wording or effects or reserved for future
# RULE:
# - Use ${RED}/${YELLOW}/${GREEN}/etc for decorative or general display output
# - Use ${RE}/${REB}/${YE}/${YEB}/${GR}/${BW} for any output where the actual meaning of the color
#   must remain trustworthy even if a theme or random twist is active
# ==============================================================================

init_base_colors() {
	# ----- STANDARD DISPLAY COLORS (TWISTABLE) -------------------------------
	RED=$'\033[1;31m'
	GREEN=$'\033[1;32m'
	YELLOW=$'\033[1;33m'
	BLUE=$'\033[1;34m'
	MAGENTA=$'\033[1;35m'
	CYAN=$'\033[1;36m'
	WHITE=$'\033[1;37m'
	BWHITE=$'\033[1;37m'
	NC=$'\033[0m'

	# ----- FIXED SEMANTIC WARNING COLORS (DO NOT TWIST) ----------------------
	# KEEP SEMANTIC WARNING COLORS STABLE NO MATTER WHAT THEME IS ACTIVE
    # Add '5;' after the bracket for the blinking effect
    RE=$'\033[1;1;31m'  # Solid Bold Red
    REB=$'\033[5;1;31m'  # Blinking Bold Red
    YE=$'\033[1;1;33m'    # Solid Bold Yellow (Stable Warning)
    YEB=$'\033[5;1;33m'    # Blinking Bold Yellow (Stable Warning)
    GR=$'\033[1;32m'    # Solid Bold Green (All Clear)
    BW=$'\033[1;37m'    # Bright White
}

ansi_color() {
	case "$1" in
		0)  printf '\033[0m' ;;
		30) printf '\033[1;30m' ;;
		31) printf '\033[1;31m' ;;
		32) printf '\033[1;32m' ;;
		33) printf '\033[1;33m' ;;
		34) printf '\033[1;34m' ;;
		35) printf '\033[1;35m' ;;
		36) printf '\033[1;36m' ;;
		37) printf '\033[1;37m' ;;
		90) printf '\033[1;30m' ;;
		91) printf '\033[1;31m' ;;
		92) printf '\033[1;32m' ;;
		93) printf '\033[1;33m' ;;
		94) printf '\033[1;34m' ;;
		95) printf '\033[1;35m' ;;
		96) printf '\033[1;36m' ;;
		97) printf '\033[1;97m' ;;
		*)  printf '\033[0m' ;;
	esac
}

set_color_var() {
	local var_name="$1"
	local ansi_num="$2"
	printf -v "$var_name" '%s' "$(ansi_color "$ansi_num")"
}

apply_color_map() {
    printf '\033[0m'
	local red_code="$1"
	local green_code="$2"
	local yellow_code="$3"
	local blue_code="$4"
	local magenta_code="$5"
	local cyan_code="$6"
	local white_code="$7"
	local bwhite_code="$8"

	set_color_var RED     "$red_code"
	set_color_var GREEN   "$green_code"
	set_color_var YELLOW  "$yellow_code"
	set_color_var BLUE    "$blue_code"
	set_color_var MAGENTA "$magenta_code"
	set_color_var CYAN    "$cyan_code"
	set_color_var WHITE   "$white_code"
	set_color_var BWHITE  "$bwhite_code"

	# KEEP RESET STABLE
	NC=$'\033[0m'

	# KEEP SEMANTIC WARNING COLORS STABLE NO MATTER WHAT THEME IS ACTIVE
    # Add '5;' after the bracket for the blinking effect
    RE=$'\033[1;1;31m'  # Solid Bold Red
    REB=$'\033[5;1;31m'  # Blinking Bold Red
    YE=$'\033[1;1;33m'    # Solid Bold Yellow (Stable Warning)
    YEB=$'\033[5;1;33m'    # Blinking Bold Yellow (Stable Warning)
    GR=$'\033[1;32m'    # Solid Bold Green (All Clear)
    BW=$'\033[1;37m'    # Bright White

}

is_bad_palette() {
	local c0="${1:-0}" c1="${2:-0}" c2="${3:-0}" c3="${4:-0}"
	local c4="${5:-0}" c5="${6:-0}" c6="${7:-0}" c7="${8:-0}"

	# INDEX MAP:
	# c0=RED c1=GREEN c2=YELLOW c3=BLUE
	# c4=MAGENTA c5=CYAN  c6=WHITE  c7=BWHITE

	# ----- BLOCK HARD-TO-READ OR MUDDY PAIRS -------------------------------
	[[ "$c2" == 33 && "$c6" == 37 ]] && return 0   # YELLOW / WHITE
	[[ "$c2" == 33 && "$c7" == 97 ]] && return 0   # YELLOW / BWHITE
	[[ "$c6" == 37 && "$c5" == 36 ]] && return 0   # WHITE / CYAN
	[[ "$c1" == 32 && "$c5" == 36 ]] && return 0   # GREEN / CYAN
	[[ "$c0" == 31 && "$c4" == 35 ]] && return 0   # RED / MAGENTA

	return 1
}

twisted_randomize() {
	local i j tmp attempt=0 max_attempts=20
	local codes

	# ----- CONTRAST-GUARDED RANDOM PALETTE -----------------------------------
	# PURPOSE:
	# Shuffle the 8 twistable display colors, but reject known bad / muddy
	# combinations that reduce readability.
	#
	# IMPORTANT:
	# - This function is called by: twisted random
	# - This is NOT the semantic warning block; RE / YE / GR / BW stay fixed
	# - We reset the candidate palette on each attempt, shuffle it, then test it
	# - If a bad palette is detected, we try again up to max_attempts
	#
	# SET -e / SET -u SAFETY:
	# - Use ${codes[n]:-0} in the guard call to avoid unbound crashes
	# - Use ((attempt+=1)) instead of ((attempt++)) so set -e does not pop out
	# -------------------------------------------------------------------------

	while (( attempt < max_attempts )); do
		# ----- RESET TO BASE ORDER EACH ATTEMPT ------------------------------
		# KEEP 8 SLOTS:
		#   RED GREEN YELLOW BLUE MAGENTA CYAN WHITE BWHITE
		codes=(31 32 33 34 35 36 37 97)

		# ----- FISHER-YATES SHUFFLE -----------------------------------------
		for (( i=${#codes[@]}-1; i>0; i-- )); do
			j=$(( RANDOM % (i + 1) ))
			tmp="${codes[i]}"
			codes[i]="${codes[j]}"
			codes[j]="$tmp"
		done

		# ----- CONTRAST GUARD -----------------------------------------------
		# If palette is acceptable, stop trying and apply it
		if ! is_bad_palette \
			"${codes[0]:-0}" "${codes[1]:-0}" "${codes[2]:-0}" "${codes[3]:-0}" \
			"${codes[4]:-0}" "${codes[5]:-0}" "${codes[6]:-0}" "${codes[7]:-0}"; then
			break
		fi

		# ----- TRY AGAIN -----------------------------------------------------
		((attempt+=1))
	done

	# ----- FALLBACK NOTICE ---------------------------------------------------
	# Very unlikely, but if every attempt was rejected, last shuffle still gets
	# applied so the feature never appears frozen.
	if (( attempt == max_attempts )); then
		echo -e "${YE} = = > Contrast Guard Fallback: Using Last Shuffle.${NC}"
	fi

	# ----- APPLY ACCEPTED PALETTE -------------------------------------------
	apply_color_map \
		"${codes[0]}" "${codes[1]}" "${codes[2]}" "${codes[3]}" \
		"${codes[4]}" "${codes[5]}" "${codes[6]}" "${codes[7]}"
}

twisted_theme() {
	local theme_name="${1,,}"

	case "$theme_name" in
		classic)
			# STANDARD / EXPECTED LAYOUT
			apply_color_map 31 32 33 34 35 36 37 97
			;;

		mellow)
			# SOFTER / FRIENDLIER LOOK
			apply_color_map 35 36 33 34 95 96 37 97
			;;

		danger)
			# HOT / AGGRESSIVE / ALERT-HEAVY LOOK
			apply_color_map 91 31 93 35 95 33 37 97
			;;

		ice)
			# COOL / TECH / FROSTED LOOK
			apply_color_map 94 96 97 34 95 36 37 97
			;;

		twisted)
			# PURPOSEFULLY OFF-KILTER BUT STILL CURATED
			apply_color_map 36 35 31 33 32 94 97 93
			;;

		mono)
			# MINIMAL / ALMOST MONOCHROME
			apply_color_map 37 97 37 90 37 97 37 97
			;;

		*)
			echo -e "${YE} = = > Unknown twisted theme: $theme_name${NC}"
			echo -e "${WHITE} = = > Available themes: classic mellow danger ice twisted mono${NC}"
			return 1
			;;
	esac
}

twisted_manual() {
	local red_code green_code yellow_code blue_code
	local magenta_code cyan_code white_code bwhite_code

	echo
	echo -e "${WHITE} = = > Enter ANSI color numbers for the TWISTABLE display palette.${NC}"
	echo -e "${WHITE} = = > Common values: 31 32 33 34 35 36 37 91 92 93 94 95 96 97${NC}"
	echo -e "${WHITE} = = > Semantic warning colors RE/YE/GR will remain fixed.${NC}"
	echo

	read -r -p " = = > RED ansi number      : " red_code
	read -r -p " = = > GREEN ansi number    : " green_code
	read -r -p " = = > YELLOW ansi number   : " yellow_code
	read -r -p " = = > BLUE ansi number     : " blue_code
	read -r -p " = = > MAGENTA ansi number  : " magenta_code
	read -r -p " = = > CYAN ansi number     : " cyan_code
	read -r -p " = = > WHITE ansi number    : " white_code
	read -r -p " = = > BWHITE ansi number   : " bwhite_code

	apply_color_map \
		"$red_code" "$green_code" "$yellow_code" "$blue_code" \
		"$magenta_code" "$cyan_code" "$white_code" "$bwhite_code"
}

show_current_color_map() {
	echo
	echo -e "${WHITE} = = > Current Twisted Display Palette Preview:${NC}"
	echo -e "     ${RED}RED${NC}  ${GREEN}GREEN${NC}  ${YELLOW}YELLOW${NC}  ${BLUE}BLUE${NC}"
	echo -e "     ${MAGENTA}MAGENTA${NC}  ${CYAN}CYAN${NC}  ${WHITE}WHITE${NC}  ${BWHITE}BWHITE${NC}"
	echo
	echo -e "${WHITE} = = > Fixed Semantic Warning Palette Preview:${NC}"
	echo -e "     ${GR}GR = SAFE / OK${NC}"
	echo -e "     ${YE}YE = CAUTION / NOTICE${NC}"
	echo -e "     ${YEB}YEB = Blinking CAUTION / NOTICE${NC}"
	echo -e "     ${RE}RE = RISK / FAIL / DANGER${NC}"
	echo -e "     ${REB}REB = Blinking RISK / FAIL / DANGER${NC}"
	echo
}

twisted() {
	local mode="${1,,}"

	case "$mode" in
		random)
			twisted_randomize
			;;
		theme)
			twisted_theme "$2"
			;;
		manual)
			twisted_manual
			;;
		show|preview)
			show_current_color_map
			return 0
			;;
		reset|default|classic)
			twisted_theme classic
			;;
		*)
			echo -e "${YE} = = > Invalid Twisted Mode.${NC}"
			return 1
			;;
	esac
}

# ----- INITIALIZE DEFAULT COLORS AT STARTUP -----------------------------------
init_base_colors

# engine
 
#=================================================================================================================

# menus     

# ===== TWISTED MENU ===========================================================
# PURPOSE:
# Small menu wrapper for the twisted color/theme engine.
#
# REQUIRES:
# - twisted()
# - twisted_theme()
# - show_current_color_map()
# - pause()
#
# NOTES:
# - Standard display colors may be remapped
# - Semantic warning colors RE/YE/GR remain fixed
# - This menu is cosmetic-facing and safe to expose under Advanced Tools
# ==============================================================================

run_twisted_menu() {
	local choice theme_name

	while true; do
		clear
		echo -e "${CYAN}========================================================================${NC}"
		echo -e "${CYAN}                          TWISTED COLOR MENU                            ${NC}"
		echo -e "${CYAN}========================================================================${NC}"
		echo
		echo -e "${YELLOW}     1) Randomize Display Palette${NC}"
		echo -e "${YELLOW}     2) Choose Theme Preset${NC}"
		echo -e "${YELLOW}     3) Manual Per-Color ANSI Input${NC}"
		echo -e "${YELLOW}     4) Show Current Color Preview${NC}"
		echo -e "${YELLOW}     5) Reset To Classic${NC}"
		echo
		echo -e "${YELLOW}     0) Return${NC}"
		echo
        echo -e "${YELLOW}"
		read -r -p " = = > Select option [1-5 | 0=return]: " choice
        echo -e "${NC}"

        if is_exit_token "$choice"; then
            return 0
        fi

		case "$choice" in

			1)
				echo
				echo -e "${YELLOW} = = > Randomizing display palette...${NC}"
				twisted random
				pause
				;;

			2)
				echo
				echo -e "${WHITE}Available themes:${NC}"
				echo -e "${WHITE}  1) ${CYAN}classic${NC}"
				echo -e "${WHITE}  2) ${CYAN}mellow${NC}"
				echo -e "${WHITE}  3) ${CYAN}danger${NC}"
				echo -e "${WHITE}  4) ${CYAN}ice${NC}"
				echo -e "${WHITE}  5) ${CYAN}twisted${NC}"
				echo -e "${WHITE}  6) ${CYAN}mono${NC}"
				echo -e "${WHITE}  0) Return${NC}"
				echo

				read -r -p " = = > Select theme [1-6 | 0=return]: " theme_name
				theme_name="${theme_name,,}"
				theme_name="${theme_name//[[:space:]]/}"

				case "$theme_name" in
					1) twisted theme classic ;;
					2) twisted theme mellow ;;
					3) twisted theme danger ;;
					4) twisted theme ice ;;
					5) twisted theme twisted ;;
					6) twisted theme mono ;;
					0|q)
						echo -e "${YE} = = > Theme selection canceled.${NC}"
						pause
						continue
						;;
					*)
						echo -e "${YE} = = > Invalid theme selection.${NC}"
						pause
						continue
						;;
				esac

				pause
				;;

			3)
				echo
				echo -e "${YELLOW} = = > Manual ANSI mapping selected.${NC}"
				twisted manual
				pause
				;;

			4)
				show_current_color_map
				pause
				;;

			5)
				echo
				echo -e "${YELLOW} = = > Resetting display palette to classic...${NC}"
				twisted reset
				pause
				;;


			*)
				echo
				echo -e "${YE} = = > Invalid selection.${NC}"
				pause
				;;
		esac
	done
}

# END OF COLOR SYSTEM / TWISTED THEME ENGINE ===================================
