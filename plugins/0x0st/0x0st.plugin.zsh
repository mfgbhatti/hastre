# 0x0.st: upload files and print the URL.
# https://0x0.st

(( ${+commands[curl]} )) || return

# _0x0st_post URL [curl args...]
# Send a form to URL. On success print the reply on stdout and the server's
# X-Token / X-Expires headers on stderr; on an HTTP error print the server's
# message on stderr and return 1.
function _0x0st_post {
  emulate -L zsh
  local url=$1 hdr out code body rc
  shift

  hdr=$(mktemp) || return 1
  {
    out=$(curl -sS -D $hdr -w $'\n%{http_code}' "$@" $url)
    rc=$?
    (( rc )) && return $rc

    # curl appended "\n<http code>" to the reply body.
    code=${out##*$'\n'}
    body=${out%$'\n'*}
    body=${body%$'\n'}

    if [[ $code != 2* ]]; then
      print -u2 "0x0_st: HTTP $code${body:+: $body}"
      return 1
    fi
    [[ -z $body ]] || print -r -- $body
    grep -iE '^x-(token|expires):' $hdr | tr -d '\r' >&2
    return 0
  } always {
    rm -f -- $hdr
  }
}

function 0x0_st {
  emulate -L zsh

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
  If the server refuses the request, its message is printed to stderr and
  the exit status is 1.

Examples:
  0x0_st file.png
  0x0_st -s -e 24 notes.txt
  echo 'hi' | 0x0_st
  0x0_st -u https://example.com/image.jpg
  0x0_st -d TOKEN https://0x0.st/abcd.png"

  local secret="" expires="" remote="" file=""
  while (( $# )); do
    case $1 in
      -h|--help) print -r -- "$usage"; return 0 ;;
      -s|--secret) secret=1 ;;
      -e|--expires)
        [[ $2 == <-> ]] || {
          print -u2 "0x0_st: -e needs a number (hours, or a Unix timestamp in ms)"
          return 1
        }
        expires=$2
        shift ;;
      -u|--url)
        [[ -n $2 ]] || { print -u2 "0x0_st: -u needs a URL"; return 1 }
        remote=$2
        shift ;;
      -d|--delete)
        (( $# >= 3 )) || { print -u2 "0x0_st: -d needs TOKEN and URL"; return 1 }
        _0x0st_post $3 --form-string "token=$2" --form-string "delete="
        return ;;
      -?*) print -u2 "0x0_st: unknown option '$1' (try -h)"; return 1 ;;
      *)
        [[ -z $file ]] || { print -u2 "0x0_st: only one FILE at a time"; return 1 }
        file=$1 ;;
    esac
    shift
  done

  if [[ -n $remote && -n $file ]]; then
    print -u2 "0x0_st: use either -u URL or a FILE, not both"
    return 1
  fi

  local -a args
  if [[ -n $remote ]]; then
    args=(--form-string "url=$remote")
  elif [[ -n $file ]]; then
    [[ -r $file ]] || { print -u2 "0x0_st: cannot read '$file'"; return 1 }
    # Quote the name so ';' or ',' in it are not parsed by curl -F.
    local name=${file//\\/\\\\}
    name=${name//\"/\\\"}
    args=(-F "file=@\"$name\"")
  else
    args=(-F "file=@-;filename=stdin.txt")
  fi
  [[ -n $secret ]] && args+=(--form-string "secret=")
  [[ -n $expires ]] && args+=(--form-string "expires=$expires")

  _0x0st_post https://0x0.st $args
}
