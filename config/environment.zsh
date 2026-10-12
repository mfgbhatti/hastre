# Editor: prefer nvim, fall back to vim, then vi. An EDITOR or VISUAL you set
# yourself (in .zshrc before Hastre loads, or in the environment) is kept.
if (($+commands[nvim])); then
  : ${EDITOR:=nvim}
  : ${VISUAL:=nvim}
elif (($+commands[vim])); then
  : ${EDITOR:=vim}
  : ${VISUAL:=vim}
else
  : ${EDITOR:=vi}
  : ${VISUAL:=vi}
fi
export EDITOR VISUAL
# npm
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PATH="$XDG_DATA_HOME/npm/bin:$PATH"
# cargo home
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export PATH="$CARGO_HOME/bin:$PATH"
# uv tools
export PATH="$HOME/.local/bin:$PATH"
# MISC
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
# go lang
export GOPATH="$XDG_DATA_HOME/go"
# gnupg
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
# nvm
export NVM_DIR="$XDG_DATA_HOME/nvm"
# Python
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
# java sdk
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
# wine prefix
export WINEPREFIX="$XDG_DATA_HOME"/wineprefixes/default

# vim: set ts=2 sts=2 sw=2 et ft=zsh :
