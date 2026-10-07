function fzf_setup_using_fzf() {
  (( ${+commands[fzf]} )) || return 1

  # we remove "fzf " prefix, this fixes really old fzf versions behaviour
  # see https://github.com/ohmyzsh/ohmyzsh/issues/12387
  local fzf_ver=${"$(fzf --version)"#fzf }

  autoload -Uz is-at-least
  is-at-least 0.48.0 ${${(s: :)fzf_ver}[1]} || return 1

  eval "$(fzf --zsh)"
}

function fzf_setup_using_base_dir() {
  local fzf_base fzf_shell fzfdirs dir

  test -d "${FZF_BASE}" && fzf_base="${FZF_BASE}"

  if [[ -z "${fzf_base}" ]]; then
    fzfdirs=(
      "${HOME}/.fzf"
      "${HOME}/.nix-profile/share/fzf"
      "${XDG_DATA_HOME:-$HOME/.local/share}/fzf"
      "${MSYSTEM_PREFIX}/share/fzf"
      "/usr/local/opt/fzf"
      "/opt/homebrew/opt/fzf"
      "/usr/share/fzf"
      "/usr/local/share/examples/fzf"
    )
    for dir in ${fzfdirs}; do
      if [[ -d "${dir}" ]]; then
        fzf_base="${dir}"
        break
      fi
    done

    if [[ -z "${fzf_base}" ]]; then
      if (( ${+commands[fzf-share]} )) && dir="$(fzf-share)" && [[ -d "${dir}" ]]; then
        fzf_base="${dir}"
      elif (( ${+commands[brew]} )) && dir="$(brew --prefix fzf 2>/dev/null)"; then
        if [[ -d "${dir}" ]]; then
          fzf_base="${dir}"
        fi
      fi
    fi
  fi

  if [[ ! -d "${fzf_base}" ]]; then
    return 1
  fi

  # Fix fzf shell directory for Arch Linux, NixOS or Void Linux packages
  if [[ ! -d "${fzf_base}/shell" ]]; then
    fzf_shell="${fzf_base}"
  else
    fzf_shell="${fzf_base}/shell"
  fi

  # Setup fzf binary path
  if (( ! ${+commands[fzf]} )) && [[ "$PATH" != *$fzf_base/bin* ]]; then
    export PATH="$PATH:$fzf_base/bin"
  fi

  # Auto-completion
  if [[ -o interactive && "$DISABLE_FZF_AUTO_COMPLETION" != "true" ]]; then
    source "${fzf_shell}/completion.zsh" 2> /dev/null
  fi

  # Key bindings
  if [[ "$DISABLE_FZF_KEY_BINDINGS" != "true" ]]; then
    source "${fzf_shell}/key-bindings.zsh"
  fi
}


function fzf_setup_using_debian() {
  if (( ! $+commands[apt] && ! $+commands[apt-get] )); then
    # Not a debian based distro
    return 1
  fi

  # NOTE: There is no need to configure PATH for debian package, all binaries
  # are installed to /usr/bin by default

  local completions key_bindings

  case $PREFIX in
    *com.termux*)
      if [[ ! -f "${PREFIX}/bin/fzf" ]]; then
        # fzf not installed
        return 1
      fi
      # Support Termux package
      completions="${PREFIX}/share/fzf/completion.zsh"
      key_bindings="${PREFIX}/share/fzf/key-bindings.zsh"
      ;;
    *)
      if [[ ! -d /usr/share/doc/fzf/examples ]]; then
        # fzf not installed
        return 1
      fi
      # Determine completion file path: first bullseye/sid, then buster/stretch
      completions="/usr/share/doc/fzf/examples/completion.zsh"
      [[ -f "$completions" ]] || completions="/usr/share/zsh/vendor-completions/_fzf"
      key_bindings="/usr/share/doc/fzf/examples/key-bindings.zsh"
      ;;
  esac

  # Auto-completion
  if [[ -o interactive && "$DISABLE_FZF_AUTO_COMPLETION" != "true" ]]; then
    source $completions 2> /dev/null
  fi

  # Key bindings
  if [[ ! "$DISABLE_FZF_KEY_BINDINGS" == "true" ]]; then
    source $key_bindings
  fi

  return 0
}


function fzf_setup_using_fedora() {
  (( $+commands[fzf] )) || return 1

  local completions="/usr/share/zsh/site-functions/fzf"
  local key_bindings="/usr/share/fzf/shell/key-bindings.zsh"

  if [[ ! -f "$completions" || ! -f "$key_bindings" ]]; then
    return 1
  fi

  if [[ -o interactive && "$DISABLE_FZF_AUTO_COMPLETION" != "true" ]]; then
    source "$completions" 2>/dev/null
  fi

  if [[ "$DISABLE_FZF_KEY_BINDINGS" != "true" ]]; then
    source "$key_bindings" 2>/dev/null
  fi

  return 0
}

# Indicate to user that fzf installation not found if nothing worked
function fzf_setup_error() {
  cat >&2 <<'EOF'
[oh-my-zsh] fzf plugin: Cannot find fzf installation directory.
Please add `export FZF_BASE=/path/to/fzf/install/dir` to your .zshrc
EOF
}

fzf_setup_using_fzf \
  || fzf_setup_using_debian \
  || fzf_setup_using_fedora \
  || fzf_setup_using_base_dir \
  || fzf_setup_error

unset -f -m 'fzf_setup_*'

if [[ -z "$FZF_DEFAULT_COMMAND" ]]; then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  elif (( $+commands[rg] )); then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
  elif (( $+commands[ag] )); then
    export FZF_DEFAULT_COMMAND='ag -l --hidden -g "" --ignore .git'
  fi
fi
