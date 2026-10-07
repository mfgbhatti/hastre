# Hastre ~/.zshenv (copy of templates/zshenv, installed by tools/hastre-setup).
#
# zsh reads this file for EVERY invocation (login, interactive, scripts), so it
# is variables only: no PATH changes, no commands, no aliases. Those belong in
# config/environments.zsh. Existing values are respected (":-").
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Point zsh at the Hastre checkout (.zshrc, .zprofile, ... are read from here).
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
