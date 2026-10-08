# Hastre — Zsh configuration
# shuck:disable=C006,C003,C002
zmodload -F zsh/files b:zf_mkdir

# Print an error message to stderr and return non-zero.
die() {
  print -u2 -r -- "[error] $*"
  return 1
}

[[ -n $ZSH ]] || typeset -gx ZSH=${${(%):-%x}:A:h}

# Make sure $ZSH_CACHE_DIR is writable, otherwise use a directory in $HOME
[[ -n $ZSH_CACHE_DIR ]] || typeset -gx ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"

if [[ ! -w "$ZSH_CACHE_DIR" ]]; then
  zf_mkdir -p -- "$ZSH_CACHE_DIR" ||
    die "failed to create ZSH_CACHE_DIR at $ZSH_CACHE_DIR"
fi

# Termux only: zsh's built-in fpath does not include site-functions, so
# completions installed there by other packages (e.g. _cargo) are never found.
# Add it here, before the fpath changes below and before compinit runs. Other
# systems already have this directory in their default fpath.
if [[ $OSTYPE == linux-android* ]]; then
  () {
    local sitefn=${PREFIX:-/data/data/com.termux/files/usr}/share/zsh/site-functions
    [[ -d $sitefn ]] && ((! ${fpath[(Ie)$sitefn]})) && fpath+=("$sitefn")
  }
fi

# Create cache and completions dir and add to $fpath
[[ -d "$ZSH_CACHE_DIR/completions" ]] || zf_mkdir -p -- "$ZSH_CACHE_DIR/completions"
((${fpath[(Ie)$ZSH_CACHE_DIR/completions]})) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)

# add a function path
fpath=($ZSH/{functions,completions} $fpath)

is_plugin() {
  local base_dir=$1
  local name=$2
  builtin test -f $base_dir/plugins/$name/$name.plugin.zsh ||
    builtin test -f $base_dir/plugins/$name/_$name
}

# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if is_plugin "$ZSH" "$plugin"; then
    fpath=("$ZSH/plugins/$plugin" $fpath)
  else
    echo "[error] plugin '$plugin' not found"
  fi
done

# Load all stock functions (from $fpath files) called below.
autoload -U compaudit compinit zrecompile
# Save the location of the current completion dump file.
if [[ -z "$ZSH_COMPDUMP" ]]; then
  ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"
fi

() {
  setopt local_options extended_glob
  autoload -Uz compinit
  if [[ -s $ZSH_COMPDUMP && -z $ZSH_COMPDUMP(#qN.mh+24) ]]; then
    compinit -C -d $ZSH_COMPDUMP
  else
    compinit -d $ZSH_COMPDUMP
  fi
  # Byte-compile the dump when it changed. zcompile is a builtin: no fork.
  [[ -s $ZSH_COMPDUMP && (! -s $ZSH_COMPDUMP.zwc || $ZSH_COMPDUMP -nt $ZSH_COMPDUMP.zwc) ]] && zcompile $ZSH_COMPDUMP
}

# Source helpers
_load_source() {
  local context filepath="$1"

  # Construct zstyle context based on path
  case "$filepath" in
  plugins/*) context="plugins:${filepath:h:t}" ;; # :h = plugins/plugin_name, :t = plugin_name
  esac

  if [[ -f "$ZSH/config/$filepath" ]]; then
    source "$ZSH/config/$filepath"
  elif [[ -f "$ZSH/$filepath" ]]; then
    source "$ZSH/$filepath"
  fi
}

# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
  _load_source "plugins/$plugin/$plugin.plugin.zsh"
done
unset plugin

# Load all of your custom configurations from custom/
for config_file ("$ZSH"/config/*.zsh(N)); do
  source "$config_file"
done
unset config_file
