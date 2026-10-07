function fzf_setup_using_fzf() {
  ((${+commands[fzf]})) || return 1

  # `fzf --zsh` needs fzf >= 0.48; on older versions fall through to the distro paths
  local init
  init="$(fzf --zsh 2>/dev/null)" && [[ -n $init ]] || return 1
  eval "$init"
}


function fzf_setup_using_debian() {
  if ((!$+commands[apt] && !$+commands[apt-get])); then
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

  [[ -f "$key_bindings" ]] || return 1
  [[ -f "$completions" ]] && source "$completions"
  source "$key_bindings"
  return 0
}

function fzf_setup_using_fedora() {
  (($+commands[fzf])) || return 1

  local completions="/usr/share/zsh/site-functions/fzf"
  local key_bindings="/usr/share/fzf/shell/key-bindings.zsh"

  if [[ ! -f "$completions" || ! -f "$key_bindings" ]]; then
    return 1
  fi

  source "$completions"
  source "$key_bindings"
  return 0
}

# Indicate to user that fzf installation not found if nothing worked
function fzf_setup_error() {
  cat >&2 <<'EOF'
[oh-my-zsh] fzf plugin: Cannot find fzf installation directory.
Please add `export FZF_BASE=/path/to/fzf/install/dir` to your .zshrc
EOF
}

fzf_setup_using_fzf ||
  fzf_setup_using_debian ||
  fzf_setup_using_fedora ||
  fzf_setup_error

unset -f -m 'fzf_setup_*'

