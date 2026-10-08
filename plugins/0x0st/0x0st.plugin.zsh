0x0_st() {
  local usage="Usage: 0x0_st [-s] [-e EXPIRES] FILE
       echo 'text' | 0x0_st [-s] [-e EXPIRES]
       0x0_st -u URL
       0x0_st -d TOKEN URL

Upload a file to https://0x0.st and print its URL.

Options:
  -h, --help        Show this help
  -s, --secret      Use a longer, hard-to-guess URL
  -e, --expires N   Keep for N hours (or a Unix epoch timestamp in ms)
  -u, --url URL     Have 0x0.st fetch a remote URL instead of uploading
  -d, --delete TOKEN URL
                    Delete an upload using the token from its upload

Notes:
  Reads from stdin when no FILE is given.
  The management token (X-Token) and expiry (X-Expires) are printed to
  stderr after each upload; keep the token if you want to delete or
  change the upload later.

Examples:
  0x0_st file.png
  0x0_st -s -e 24 notes.txt
  echo 'hi' | 0x0_st
  0x0_st -u https://example.com/image.jpg
  0x0_st -d TOKEN https://0x0.st/abcd.png"

  local secret="" expires="" remote="" file=""
  while (( $# )); do
    case "$1" in
      -h|--help) print -r -- "$usage"; return 0 ;;
      -s|--secret) secret=1 ;;
      -e|--expires) expires="$2"; shift ;;
      -u|--url) remote="$2"; shift ;;
      -d|--delete)
        if [[ -z "$2" || -z "$3" ]]; then
          print -u2 "0x0_st: -d needs TOKEN and URL"; return 1
        fi
        curl -sS -F"token=$2" -F"delete=" "$3"
        return $? ;;
      -*) print -u2 "0x0_st: unknown option '$1' (try -h)"; return 1 ;;
      *) file="$1" ;;
    esac
    shift
  done

  local -a args
  if [[ -n "$remote" ]]; then
    args=(-F"url=$remote")
  elif [[ -n "$file" ]]; then
    [[ -r "$file" ]] || { print -u2 "0x0_st: cannot read '$file'"; return 1; }
    args=(-F"file=@$file")
  else
    args=(-F"file=@-;filename=stdin.txt")
  fi
  [[ -n "$secret" ]] && args+=(-F"secret=")
  [[ -n "$expires" ]] && args+=(-F"expires=$expires")

  local hdr; hdr=$(mktemp) || return 1
  curl -sS -D "$hdr" "${args[@]}" "https://0x0.st"
  local rc=$?
  grep -iE '^x-(token|expires):' "$hdr" | tr -d '\r' >&2
  rm -f "$hdr"
  return $rc
}
