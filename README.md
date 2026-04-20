# Global Helpers

Reusable Bash helper blocks collected from larger tool scripts.

## Philosophy
- Paste-over friendly
- Marker-driven
- Heavy commentary
- Human-facing terminal output
- No runtime dependency required

## Current Categories
- core/input_and_exit.sh
- core/pause_and_display.sh
- core/text_and_path.sh
- data/csv_and_sizes.sh
- display/color_system.sh

## Intended Use
Copy the helper block you want into your script and keep the commentary with it.


helpers_input_and_exit	human interaction
helpers_text_and_path	string/path normalization
helpers_csv_and_sizes	data formatting / reporting
helpers_math_and_time	numeric + time logic
helpers_colors_and_themes	UI palette system



## House Rules
- Prefer `read -r`
- Keep prompts human-facing
- Keep marker blocks intact
- Avoid removing comments that explain why a helper exists
