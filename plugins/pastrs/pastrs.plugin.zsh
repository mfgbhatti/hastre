# paste.rs: upload text from a file or stdin and print the paste URL.
# https://paste.rs

(( ${+commands[curl]} )) || return

function paste_rs {
  emulate -L zsh

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
  A truncated paste (over the size limit, HTTP 206) prints a warning to
  stderr; any other HTTP error is reported and returns 1.
  Pasting is heavily rate limited.

Examples:
  paste_rs file.txt
  echo 'Hello, world.' | paste_rs
  paste_rs -d https://paste.rs/abcd"

  local out code body

  case $1 in
    -h|--help) print -r -- "$usage"; return 0 ;;
    -d|--delete)
      [[ -n $2 ]] || { print -u2 "paste_rs: -d needs an ID or URL"; return 1 }
      local id=${2##*/}
      id=${id%%.*}
      [[ -n $id ]] || { print -u2 "paste_rs: invalid ID or URL '$2'"; return 1 }
      out=$(curl -sS -X DELETE -w $'\n%{http_code}' "https://paste.rs/$id") || return
      ;;
    -?*)
      print -u2 "paste_rs: unknown option '$1' (try -h)"
      return 1 ;;
    *)
      (( $# <= 1 )) || { print -u2 "paste_rs: only one FILE at a time"; return 1 }
      local file=${1:-/dev/stdin}
      if [[ $file != /dev/stdin && ! -r $file ]]; then
        print -u2 "paste_rs: cannot read '$file'"
        return 1
      fi
      out=$(curl -sS --data-binary @"$file" -w $'\n%{http_code}' "https://paste.rs/") || return
      ;;
  esac

  # curl appended "\n<http code>" to the reply body.
  code=${out##*$'\n'}
  body=${out%$'\n'*}
  body=${body%$'\n'}

  case $code in
    206)
      print -u2 "paste_rs: warning: paste was truncated (over the size limit)"
      print -r -- $body ;;
    2??)
      [[ -z $body ]] || print -r -- $body ;;
    *)
      print -u2 "paste_rs: HTTP $code${body:+: $body}"
      return 1 ;;
  esac
  return 0
}
