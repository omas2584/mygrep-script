#!/bin/bash

# -- Help Message
if [[ "$1" == "--help" ]]; then
  echo "Usage: $0 [-n] [-v] search_string filename"
  echo "Options:"
  echo "  -n    Show line numbers"
  echo "  -v    Invert match (show lines that do NOT match)"
  exit 0
fi

# -- Check if enough arguments
if [[ $# -lt 2 ]]; then
  echo "Error: Not enough arguments."
  echo "Usage: $0 [-n] [-v] search_string filename"
  exit 1
fi

# -- Parse options using getopts
show_line_numbers=false
invert_match=false

while getopts ":nv" opt; do
  case $opt in
    n) show_line_numbers=true ;;
    v) invert_match=true ;;
    \?) 
      echo "Error: Unknown option -$OPTARG"
      exit 1
      ;;
  esac
done

# Shift away parsed options
shift $((OPTIND -1))

# -- Now, $1 = search_string, $2 = filename
search_string="$1"
filename="$2"

# -- Validate file existence
if [[ ! -f "$filename" ]]; then
  echo "Error: File '$filename' not found."
  exit 1
fi

# -- Read file line by line
line_number=0
while IFS= read -r line; do
  line_number=$((line_number + 1))

  # Perform case-insensitive match
  if echo "$line" | grep -iq "$search_string"; then
    match=true
  else
    match=false
  fi

  # Handle inverted match if needed
  if $invert_match; then
    if [[ "$match" == "true" ]]; then
      match=false
    else
      match=true
    fi
  fi

  if [[ "$match" == "true" ]]; then
    if $show_line_numbers; then
      echo "$line_number:$line"
    else
      echo "$line"
    fi
  fi
done < "$filename"
