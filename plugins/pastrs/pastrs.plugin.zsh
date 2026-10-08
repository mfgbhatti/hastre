paste_rs() {
  local usage="Usage: paste_rs [FILE]
       echo 'text' | paste_rs
       paste_rs -d ID_OR_URL

Upload text to https://paste.rs and print the paste URL.

Options:
  -h, --help       Show this help
  -d, --delete ID  Delete a paste (ID or full URL)

Notes:
  Reads from stdin when no FILE is given.
  Add an extension to the returned URL for rendering:
    .md  renders markdown as HTML, .py/.js/etc. syntax-highlights.
  Response 201 = fully uploaded, 206 = truncated (over size limit).
  Pasting is heavily rate limited.

Examples:
  paste_rs file.txt
  echo 'Hello, world.' | paste_rs
  paste_rs -d https://paste.rs/abcd"

  case "$1" in
    -h|--help) print -r -- "$usage"; return 0 ;;
    -d|--delete)
      [[ -z "$2" ]] && { print -u2 "paste_rs: -d needs an ID or URL"; return 1; }
      local id="${2##*/}"
      id="${id%%.*}"
      curl -sS -X DELETE "https://paste.rs/$id"
      return $? ;;
  esac

  local file="${1:-/dev/stdin}"
  if [[ "$file" != /dev/stdin && ! -r "$file" ]]; then
    print -u2 "paste_rs: cannot read '$file'"
    return 1
  fi
  curl -sS --data-binary @"$file" "https://paste.rs/"
  print
}


