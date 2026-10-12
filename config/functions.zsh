# this shell configuration is inspired
# from
# https://github.com/mayTermux/myTermux/blob/main/.aliases
# and
# https://github.com/ChrisTitusTech/mybash/blob/main/.bashrc
#
# Searches for text in all files in the current folder
ftext() {
  # -i case-insensitive
  # -I ignore binary files
  # -H causes filename to be printed
  # -r recursive search
  # -n causes line number to be printed
  # optional: -F treat search term as a literal, not a regular expression
  # optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
  grep -iIHrn --color=always "$1" . | less -r
}

# Copy and go to the directory
cpg() {
  if [ -d "$2" ]; then
    cp "$1" "$2" && cd "$2" || return
  else
    cp "$1" "$2"
  fi
}

# Move and go to the directory
mvg() {
  if [ -d "$2" ]; then
    mv "$1" "$2" && cd "$2" || return
  else
    mv "$1" "$2"
  fi
}

# Create and go to the directory
mkdirg() {
  mkdir -p "$1"
  cd "$1" || return
}

# fuzzy find and kill a process
fkill() {
  local pid

  # Use a temp file to hold selected lines
  local tmpfile
  tmpfile=$(mktemp)

  ps -eo user,pid,cmd --sort=-%mem \
    | sed 1d \
    | fzf --multi \
      --reverse \
      --header=" Select processes to kill (Tab to mark, Enter to kill)" \
      --preview 'ps -p {2} -o pid,user,%cpu,%mem,cmd' \
      --bind 'ctrl-s:toggle-sort' > "$tmpfile"

  if [[ ! -s $tmpfile ]]; then
    echo "No processes selected." >&2
    rm -f "$tmpfile"
    return 1
  fi

  while IFS= read -r line; do
    pid=$(echo "$line" | awk '{print $2}')
    if [[ -n "$pid" ]]; then
      echo "Killing PID $pid…" >&2
      if kill -TERM "$pid" 2> /dev/null; then
        echo "Sent SIGTERM to $pid" >&2
      else
        echo "SIGTERM failed for $pid, sending SIGKILL…" >&2
        kill -KILL "$pid" 2> /dev/null \
          && echo "Sent SIGKILL to $pid" >&2 \
          || echo "Failed to kill $pid" >&2
      fi
    fi
  done < "$tmpfile"

  rm -f "$tmpfile"
}

# Quick backup of a file or directory
backup() {
  local item="$1"
  if [[ -z "$item" ]]; then
    echo "[x] Usage: backup <file_or_directory>"
    return 1
  fi

  local backup_name
  backup_name="${item}.backup.$(date +%Y%m%d_%H%M%S)"
  echo "[i] Creating backup: $backup_name"

  if [[ -d "$item" ]]; then
    cp -rv "$item" "$backup_name"
  else
    cp -v "$item" "$backup_name"
  fi

  echo "[✓] Backup created: $backup_name"
}

# Find and replace text in files
freplace() {
  if [[ $# -ne 3 ]]; then
    echo "[x] Usage: freplace <search_text> <replace_text> <file_pattern>"
    echo "    Example: freplace 'old_text' 'new_text' '*.txt'"
    return 1
  fi

  local search="$1"
  local replace="$2"
  local pattern="$3"
  local -a files

  echo "[i] Searching for '$search' in files matching '$pattern'"
  echo "[i] Will replace with '$replace'"

  # Expand the glob pattern (zsh does not glob unquoted variables by default)
  files=(${~pattern}(N.))
  if (( ${#files} == 0 )); then
    echo "[x] No files match '$pattern'"
    return 1
  fi

  # Show what will be changed first
  echo "[i] Files that will be modified:"
  grep -l -- "$search" "${files[@]}" 2> /dev/null || {
    echo "[x] No files found containing '$search'"
    return 1
  }

  read -r -k 1 "REPLY?Continue with replacement? (y/N): "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sed -i.bak "s/$search/$replace/g" "${files[@]}"
    echo "[✓] Replacement completed. Original files backed up with .bak extension"
  else
    echo "[i] Operation cancelled"
  fi
}

# Quick note taking
note() {
  local note_file="$HOME/.notes"
  if [[ $# -eq 0 ]]; then
    echo "[i] Current notes:"
    cat "$note_file" 2> /dev/null || echo "[i] No notes found"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $*" >> "$note_file"
    echo "[✓] Note added"
  fi
}

# Find large files
findbig() {
  local size="${1:-100M}"
  # note: don't name this `path` -- in zsh it is tied to $PATH
  local dir="${2:-.}"
  echo "[i] Finding files larger than $size in $dir"
  find "$dir" -type f -size "+$size" -exec sh -c 'ls -lh "$@"' _ {} + 2> /dev/null | sort -k5 -hr
}

# Calculate file checksums
checksum() {
  local file="$1"
  if [[ -z "$file" ]] || [[ ! -f "$file" ]]; then
    echo "[x] Usage: checksum <file>"
    return 1
  fi

  echo "[i] Checksums for: $file"
  echo "  MD5:    $(md5sum "$file" | cut -d' ' -f1)"
  echo "  SHA1:   $(sha1sum "$file" | cut -d' ' -f1)"
  echo "  SHA256: $(sha256sum "$file" | cut -d' ' -f1)"
}

tb() {
    # Check dependency
    if ! command -v nc >/dev/null 2>&1; then
        echo "tb: 'nc' (netcat) is required." >&2
        echo "Install it with your package manager, e.g.:" >&2
        echo "  Arch:   sudo pacman -S openbsd-netcat" >&2
        echo "  Debian: sudo apt install netcat-openbsd" >&2
        echo "  Termux: pkg install netcat-openbsd" >&2
        return 127
    fi

    # Check arguments
    if [[ $# -gt 1 ]]; then
        echo "Usage: tb [file]" >&2
        return 2
    fi

    # Upload file
    if [[ $# -eq 1 ]]; then
        if [[ ! -f "$1" ]]; then
            echo "tb: file not found: $1" >&2
            return 1
        fi

        nc termbin.com 9999 < "$1"
        return $?
    fi

    # Upload stdin
    if [[ -t 0 ]]; then
        echo "tb: no input provided." >&2
        echo "Usage: tb [file]" >&2
        echo "   or: command | tb" >&2
        return 2
    fi

    nc termbin.com 9999
}

