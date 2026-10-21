# zgcrypt - encrypt/decrypt a directory with tar + zstd + gpg
#
#   zgcrypt encrypt <dir> [output.tar.zst.gpg]
#   zgcrypt decrypt <file.tar.zst.gpg> [output_dir]
#
# Aliases: zgenc, zgdec
# Settings (set before the plugin loads, e.g. in .zshrc):
#   ZGCRYPT_ZSTD_LEVEL      zstd level (default 19)
#   ZGCRYPT_ZSTD_THREADS    zstd threads, 0 = all cores (default 0)
#   ZGCRYPT_GPG_RECIPIENT   encrypt to this public key instead of a passphrase

(( $+commands[tar] && $+commands[zstd] && $+commands[gpg] )) || return

: ${ZGCRYPT_ZSTD_LEVEL:=19}
: ${ZGCRYPT_ZSTD_THREADS:=0}
: ${ZGCRYPT_GPG_RECIPIENT:=}

_zgcrypt_err() {
  print -u2 -r -- "zgcrypt: $*"
}

# Prompt on the terminal (stdin is a pipe, so pinentry can't be used) and set
# $pass in the caller's scope. Pass "confirm" to ask twice.
_zgcrypt_passphrase() {
  local p1 p2
  [[ -r /dev/tty ]] || { _zgcrypt_err "no terminal to prompt for a passphrase"; return 1 }
  read -rs "p1?Passphrase: " </dev/tty
  print -u2
  [[ -n $p1 ]] || { _zgcrypt_err "empty passphrase"; return 1 }
  if [[ $1 == confirm ]]; then
    read -rs "p2?Confirm passphrase: " </dev/tty
    print -u2
    [[ $p1 == $p2 ]] || { _zgcrypt_err "passphrases do not match"; return 1 }
  fi
  pass=$p1
}

_zgcrypt_encrypt() {
  emulate -L zsh
  setopt pipe_fail

  local src=$1 out pass=
  [[ -n $src ]] || { _zgcrypt_err "usage: zgcrypt encrypt <dir> [output]"; return 1 }
  [[ -d $src ]] || { _zgcrypt_err "'$src' is not a directory"; return 1 }

  src=${src:A}
  out=${2:-${src:t}.tar.zst.gpg}
  [[ ! -e $out ]] || { _zgcrypt_err "'$out' already exists"; return 1 }

  local -a gpg_args=(--yes --output "$out")
  if [[ -n $ZGCRYPT_GPG_RECIPIENT ]]; then
    gpg_args+=(--encrypt --recipient "$ZGCRYPT_GPG_RECIPIENT")
  else
    _zgcrypt_passphrase confirm || return 1
    gpg_args+=(--batch --pinentry-mode loopback --passphrase-fd 3
               --symmetric --cipher-algo AES256)
  fi

  print -r -- "Encrypting '$src' -> '$out' ..."
  if tar -C "${src:h}" -cf - "${src:t}" \
      | zstd "-$ZGCRYPT_ZSTD_LEVEL" "-T$ZGCRYPT_ZSTD_THREADS" --quiet \
      | gpg "${gpg_args[@]}" 3<<<"$pass"; then
    print -r -- "Done: $out"
  else
    rm -f -- "$out"
    _zgcrypt_err "encryption failed"
    return 1
  fi
}

_zgcrypt_decrypt() {
  emulate -L zsh
  setopt pipe_fail

  local in=$1 dest=${2:-.} pass=
  [[ -n $in ]] || { _zgcrypt_err "usage: zgcrypt decrypt <file> [output_dir]"; return 1 }
  [[ -f $in ]] || { _zgcrypt_err "'$in' is not a file"; return 1 }

  _zgcrypt_passphrase || return 1
  mkdir -p -- "$dest" || return 1

  print -r -- "Decrypting '$in' into '$dest' ..."
  gpg --batch --pinentry-mode loopback --passphrase-fd 3 --decrypt "$in" 3<<<"$pass" \
    | zstd -d "-T$ZGCRYPT_ZSTD_THREADS" --quiet \
    | tar -C "$dest" -xf - \
    && print -r -- "Done." \
    || { _zgcrypt_err "decryption failed"; return 1 }
}

zgcrypt() {
  local cmd=$1
  (( $# )) && shift
  case $cmd in
    encrypt|enc|e) _zgcrypt_encrypt "$@" ;;
    decrypt|dec|d) _zgcrypt_decrypt "$@" ;;
    *)
      print -u2 -r -- "usage: zgcrypt encrypt <dir> [output]"
      print -u2 -r -- "       zgcrypt decrypt <file> [output_dir]"
      return 1
      ;;
  esac
}

alias zgenc='zgcrypt encrypt'
alias zgdec='zgcrypt decrypt'
