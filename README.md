# Global Helpers

Reusable Bash helper blocks collected from larger tool scripts.

## Philosophy
- Paste-over friendly
- Marker-driven
- Heavy commentary
- Human-facing terminal output
- No runtime dependency required

## Current Categories
- helpers_input_and_exit	'human interaction'
- helpers_text_and_path	'string/path normalization'
- helpers_csv_and_sizes	'data formatting / reporting'
- helpers_colors_and_themes	'UI palette system'
- helpers_math_and_time	'numeric + time logic'

## Intended Use
Copy the helper block you want into your script and keep the commentary with it.









## House Rules
- Prefer `read -r`
- Keep prompts human-facing
- Keep marker blocks intact
- Avoid removing comments that explain why a helper exists
