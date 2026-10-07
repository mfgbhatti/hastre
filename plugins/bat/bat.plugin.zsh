# bat: a `cat` clone with syntax highlighting and git integration.
# https://github.com/sharkdp/bat
#
# Debian/Ubuntu install the binary as `batcat`; this plugin handles both names.

typeset -g _bat_cmd=
if (( ${+commands[bat]} )); then
  _bat_cmd=bat
elif (( ${+commands[batcat]} )); then
  _bat_cmd=batcat
  alias bat=batcat
else
  return
fi

# Theme (bat's own BAT_THEME wins if you already set it).
export BAT_THEME="${BAT_THEME:-OneHalfDark}"

# Opt in to replacing `cat` (set before loading Hastre):
#   BAT_ALIAS_CAT=1
# Plain output, no paging, so it behaves like cat in a terminal and in pipes.
[[ -n ${BAT_ALIAS_CAT-} ]] && alias cat="$_bat_cmd --plain --paging=never"

alias b="$_bat_cmd"
alias bp="$_bat_cmd --plain"                     # no line numbers or decorations
alias bpp="$_bat_cmd --plain --paging=never"     # same, never page
alias bd="$_bat_cmd --diff"                      # show only git-modified lines
alias ba="$_bat_cmd --show-all"                  # show tabs, spaces, newlines
alias bt="$_bat_cmd --list-themes"
alias bL="$_bat_cmd --list-languages"

# Colorized man pages: bman ls
function bman {
  emulate -L zsh
  MANPAGER="sh -c 'col -bx | $_bat_cmd --language=man --plain'" command man "$@"
}

# Colorized --help: bhelp git commit
function bhelp {
  emulate -L zsh
  [[ -n $1 ]] || { print "Usage: bhelp <command> [subcommand...]"; return 1; }
  "$@" --help 2>&1 | $_bat_cmd --language=help --plain
}

# Follow a log file with highlighting: blog /var/log/syslog
function blog {
  emulate -L zsh
  [[ -f $1 ]] || { print "Usage: blog <file>"; return 1; }
  tail -f -- "$1" | $_bat_cmd --language=log --plain --paging=never
}

# Review uncommitted changes in the current repo with bat: bgd
function bgd {
  emulate -L zsh
  git rev-parse --is-inside-work-tree &>/dev/null ||
    { print "bgd: not inside a git repository"; return 1; }
  git diff --name-only --relative --diff-filter=d -z |
    xargs -0 -r $_bat_cmd --diff
}
