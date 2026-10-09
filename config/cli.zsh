# hastre command line interface
#
#   hastre help
#   hastre version
#   hastre reload
#   hastre update [--check]
#   hastre plugin list [--enabled]
#   hastre plugin info <plugin>
#   hastre plugin load <plugin> [...]
#   hastre plugin enable <plugin> [...]
#   hastre plugin disable <plugin> [...]
#
# The layout follows Oh My Zsh's lib/cli.zsh: `hastre` dispatches to
# `_hastre::<command>`. Internal helpers use the `_hastre_` prefix (single
# underscore) so they can never be reached as a command.

hastre() {
  setopt localoptions noksharrays

  if (( $# == 0 )); then
    _hastre::help >&2
    return 1
  fi

  local command=$1
  shift

  if (( ! ${+functions[_hastre::$command]} )); then
    _hastre::help >&2
    return 1
  fi

  _hastre::$command "$@"
}

# Completion
_hastre() {
  local -a cmds subcmds opts args
  local -aU names

  cmds=(
    'help:Usage information'
    'plugin:Manage plugins'
    'reload:Reload the current zsh session'
    'update:Update Hastre'
    'version:Show the version'
  )

  if (( CURRENT == 2 )); then
    _describe 'command' cmds
  elif (( CURRENT == 3 )); then
    case $words[2] in
    plugin)
      subcmds=(
        'disable:Disable plugin(s) in .zshrc'
        'enable:Enable plugin(s) in .zshrc'
        'info:Show the README of a plugin'
        'list:List plugins'
        'load:Load plugin(s) in this session only'
      )
      _describe 'command' subcmds
      ;;
    update)
      opts=('--check:Only check for new commits')
      _describe -o 'options' opts
      ;;
    esac
  elif (( CURRENT >= 4 )) && [[ $words[2] == plugin ]]; then
    # plugins already given on the command line are not offered again
    args=(${words[4,$(( CURRENT - 1 ))]})
    case $words[3] in
    list)
      (( CURRENT == 4 )) || return 0
      opts=('--enabled:List enabled plugins only')
      _describe -o 'options' opts
      return 0
      ;;
    info)
      (( CURRENT == 4 )) || return 0
      names=(${(f)"$(_hastre_available_plugins)"})
      ;;
    load) names=(${(f)"$(_hastre_available_plugins)"}) ;;
    enable) names=(${${(f)"$(_hastre_available_plugins)"}:|plugins}) ;;
    disable) names=($plugins) ;;
    *) return 0 ;;
    esac
    names=(${names:|args})
    (( $#names )) && _describe 'plugin' names
  fi
  return 0
}

# If run from a script, do not set the completion function
if (( ${+functions[compdef]} )); then
  compdef _hastre hastre
fi

## Helpers

_hastre_info() { print -r -- "[info] $*"; }
_hastre_warn() { print -u2 -r -- "[warn] $*"; }

# Succeed if $1 looks like a plugin name (no slashes, spaces or glob characters).
_hastre_valid_name() { [[ $1 =~ '^[A-Za-z0-9_.+-]+$' ]]; }

# Run git inside the Hastre checkout.
_hastre_git() { command git -C "$ZSH" --no-pager "$@"; }

# Print the names of all plugins in $ZSH/plugins, one per line.
_hastre_available_plugins() {
  local dir
  for dir in "$ZSH"/plugins/*(-/N); do
    is_plugin "$ZSH" "${dir:t}" && print -r -- "${dir:t}"
  done
  return 0
}

# Print "<version> (<branch>, <commit>)", or just the version without git.
_hastre_version_string() {
  local version branch commit
  [[ -r $ZSH/VERSION ]] && read -r version < "$ZSH/VERSION"
  : ${version:=unknown}
  if (( $+commands[git] )) && [[ -e $ZSH/.git ]]; then
    branch=$(_hastre_git symbolic-ref --quiet --short HEAD 2>/dev/null) || branch=detached
    commit=$(_hastre_git rev-parse --short HEAD 2>/dev/null)
    print -r -- "$version ($branch, $commit)"
  else
    print -r -- "$version"
  fi
}

## Commands

_hastre::help() {
  cat <<EOT

Usage: hastre <command> [options]

Available commands:

  help                          Print this help message
  plugin <command>              Manage plugins
  reload                        Reload the current zsh session
  update [--check]              Update Hastre (git checkouts only)
  version                       Show the version

Plugin commands:

  plugin list [--enabled]       List plugins
  plugin info <plugin>          Show the README of a plugin
  plugin load <plugin> ...      Load plugin(s) in this session only
  plugin enable <plugin> ...    Enable plugin(s) in your .zshrc
  plugin disable <plugin> ...   Disable plugin(s) in your .zshrc

EOT
}

_hastre::version() {
  _hastre_version_string
}

_hastre::reload() {
  # Delete the completion dump (and its compiled copy) so that it is rebuilt
  command rm -f -- "$ZSH_COMPDUMP" "$ZSH_COMPDUMP.zwc"

  local zsh=${ZSH_ARGZERO:-${functrace[-1]%:*}}

  # Check whether to run a login shell
  [[ $zsh = -* || -o login ]] && exec -l "${zsh#-}" || exec "$zsh"
}

_hastre::update() {
  local check=0
  case ${1-} in
  '') ;;
  --check) check=1 ;;
  *)
    print -u2 "Usage: hastre update [--check]"
    return 1
    ;;
  esac

  if (( ! $+commands[git] )); then
    die "git is not installed"
    return 1
  fi

  # Only a git checkout can be updated
  if [[ ! -e $ZSH/.git ]]; then
    die "$ZSH is not a git checkout (no .git), update it by hand"
    return 1
  fi

  local branch upstream counts
  local -a c

  branch=$(_hastre_git symbolic-ref --quiet --short HEAD) || {
    die "HEAD is detached, check out a branch first"
    return 1
  }
  upstream=$(_hastre_git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null) || {
    die "branch '$branch' has no upstream branch"
    return 1
  }

  if (( ! check )) && [[ -n $(_hastre_git status --porcelain --untracked-files=no) ]]; then
    die "tracked files in $ZSH have local changes, commit or stash them first"
    return 1
  fi

  _hastre_info "fetching $upstream..."
  _hastre_git fetch --quiet || {
    die "git fetch failed"
    return 1
  }

  counts=$(_hastre_git rev-list --left-right --count "HEAD...$upstream") || {
    die "could not compare $branch with $upstream"
    return 1
  }
  c=(${=counts}) # c[1] = commits only here, c[2] = commits only upstream

  if (( c[2] == 0 )); then
    _hastre_info "$branch is up to date with $upstream: $(_hastre_version_string)"
    (( c[1] )) && _hastre_info "$c[1] local commit(s) not on $upstream"
    return 0
  fi

  if (( c[1] )); then
    die "$branch has diverged from $upstream (ahead $c[1], behind $c[2]), resolve it with git by hand"
    return 1
  fi

  _hastre_info "$c[2] new commit(s) on $upstream:"
  _hastre_git log --oneline --no-decorate --max-count=20 "HEAD..$upstream"
  (( c[2] > 20 )) && print "..."
  (( check )) && return 0

  local before=$(_hastre_version_string)
  _hastre_git merge --ff-only --quiet "$upstream" || {
    die "could not fast-forward $branch to $upstream"
    return 1
  }
  _hastre_info "updated: $before -> $(_hastre_version_string)"

  if [[ -o interactive ]]; then
    _hastre_info "reloading..."
    _hastre::reload
  else
    _hastre_info "start a new zsh session to use the update"
  fi
}

_hastre::plugin() {
  if (( $# == 0 || ! ${+functions[_hastre::plugin::$1]} )); then
    cat >&2 <<EOT

Usage: hastre plugin <command> [options]

Available commands:

  disable <plugin> ...  Disable plugin(s) in your .zshrc
  enable <plugin> ...   Enable plugin(s) in your .zshrc
  info <plugin>         Show the README of a plugin
  list [--enabled]      List plugins
  load <plugin> ...     Load plugin(s) in this session only

EOT
    return 1
  fi

  local command=$1
  shift
  _hastre::plugin::$command "$@"
}

_hastre::plugin::list() {
  case ${1-} in
  '' | --enabled) ;;
  *)
    print -u2 "Usage: hastre plugin list [--enabled]"
    return 1
    ;;
  esac

  local -a all enabled disabled
  all=(${(f)"$(_hastre_available_plugins)"})
  enabled=($plugins)
  disabled=(${all:|enabled})

  # If the output is piped, print one name per line
  if [[ ! -t 1 ]]; then
    if [[ ${1-} == --enabled ]]; then
      (( $#enabled )) && print -rl -- $enabled
    else
      (( $#all )) && print -rl -- $all
    fi
    return 0
  fi

  if (( $#enabled )); then
    print -P "%U%BEnabled plugins%b%u:"
    print -lac -- $enabled
  fi
  if [[ ${1-} != --enabled ]] && (( $#disabled )); then
    (( $#enabled )) && echo
    print -P "%U%BAvailable plugins%b%u:"
    print -lac -- $disabled
  fi
  return 0
}

_hastre::plugin::info() {
  if [[ -z ${1-} ]]; then
    print -u2 "Usage: hastre plugin info <plugin>"
    return 1
  fi
  if ! _hastre_valid_name "$1" || [[ ! -d $ZSH/plugins/$1 ]]; then
    die "'$1' plugin not found"
    return 1
  fi

  local readme=$ZSH/plugins/$1/README.md
  if [[ ! -f $readme ]]; then
    die "the '$1' plugin doesn't have a README file"
    return 1
  fi

  # If being piped, just cat the README
  if [[ ! -t 1 ]]; then
    cat "$readme"
    return $?
  fi

  # Enrich the README display depending on the tools we have
  case 1 in
  ${+commands[glow]}) glow -p "$readme" ;;
  ${+commands[bat]}) bat -l md --style plain "$readme" ;;
  ${+commands[less]}) less "$readme" ;;
  *) cat "$readme" ;;
  esac
}

# Load plugins into the running shell. Nothing is written to .zshrc, so the
# plugins are gone in the next session. Plugins are sourced from inside this
# function, so a plugin that declares variables with a bare `typeset` or
# `local` keeps them function-local; use `hastre plugin enable` for those.
_hastre::plugin::load() {
  if (( $# == 0 )); then
    print -u2 "Usage: hastre plugin load <plugin> [...]"
    return 1
  fi

  local plugin base has_completion=0
  local -a comp_files

  for plugin in "$@"; do
    if ! _hastre_valid_name "$plugin" || ! is_plugin "$ZSH" "$plugin"; then
      _hastre_warn "plugin '$plugin' not found"
      continue
    fi
    base=$ZSH/plugins/$plugin

    # Add its directory to $fpath unless it is already there
    (( ${fpath[(Ie)$base]} )) || fpath=("$base" $fpath)

    # Remember if there is something for compinit to pick up
    comp_files=($base/_*(N))
    (( has_completion )) || has_completion=$(( $#comp_files > 0 ))

    [[ -f $base/$plugin.plugin.zsh ]] && source "$base/$plugin.plugin.zsh"
  done

  # -D: do not write a dump file, this session is the only one that has the
  # plugins. -d: keep using the same dump file location as hastre.zsh.
  if (( has_completion )); then
    compinit -D -d "$ZSH_COMPDUMP"
  fi
  return 0
}

_hastre::plugin::enable() {
  if (( $# == 0 )); then
    print -u2 "Usage: hastre plugin enable <plugin> [...]"
    return 1
  fi

  local plugin
  local -a valid
  for plugin in "$@"; do
    if ! _hastre_valid_name "$plugin" || ! is_plugin "$ZSH" "$plugin"; then
      _hastre_warn "plugin '$plugin' not found"
    else
      valid+=("$plugin")
    fi
  done
  (( $#valid )) || return 1

  _hastre_edit_plugins enable "${valid[@]}" || return 1
  [[ ! -o interactive ]] || _hastre::reload
}

_hastre::plugin::disable() {
  if (( $# == 0 )); then
    print -u2 "Usage: hastre plugin disable <plugin> [...]"
    return 1
  fi

  _hastre_edit_plugins disable "$@" || return 1
  [[ ! -o interactive ]] || _hastre::reload
}

## Editing the plugins=( ... ) array of .zshrc
#
# Only the plain forms are edited: exactly one `plugins=( ... )` assignment
# made of plugin names, on one line or spread over several lines, with
# comments allowed. Anything else (`plugins+=(`, several assignments,
# variables or quotes inside the array) is left alone and the user is told to
# edit the file by hand.

# Split line $1 of a plugins=( ... ) block into three parts and set
# reply=(left names right) so that line == left + names + right.
#   $2: 1 if this is the first line of the block (holds `plugins=(`)
#   $3: 1 if this is the last line of the block (holds `)`)
# `left` is the indentation (plus `plugins=(` on the first line), `right` is
# everything from the closing `)` or from a comment onward.
_hastre_split_plugin_line() {
  local line=$1 first=$2 last=$3 left= right= code tail
  code=${line%%\#*}
  tail=${line#"$code"}

  if (( first )); then
    left=${code%%plugins=\(*}'plugins=('
    code=${code#*plugins=\(}
  else
    left=${code%%[^[:space:]]*}
    code=${code#"$left"}
  fi

  if (( last )); then
    right=")${code#*\)}${tail}"
    code=${code%%\)*}
  else
    right=$tail
  fi

  reply=("$left" "$code" "$right")
}

# Find the plugins=( ... ) block in the array $lines of the caller (zsh scopes
# locals dynamically). Sets reply=(first_line last_line). When the block can't
# be edited safely, prints why and returns 1.
_hastre_find_block() {
  local -a starts
  local -i i e s
  local code t

  for (( i = 1; i <= $#lines; i++ )); do
    [[ $lines[i] =~ '^[[:space:]]*plugins\+?=\(' ]] && starts+=($i)
  done

  if (( $#starts != 1 )) || [[ $lines[starts[1]] =~ '^[[:space:]]*plugins\+=\(' ]]; then
    print -u2 -r -- "expected exactly one plugins=( ... ) assignment, found $#starts"
    return 1
  fi
  s=$starts[1]

  for (( e = s; e <= $#lines; e++ )); do
    code=${lines[e]%%\#*}
    (( e == s )) && code=${code#*plugins=\(}
    [[ $code == *\)* ]] && break
  done
  if (( e > $#lines )); then
    print -u2 -r -- "the plugins=( array starting at line $s is never closed"
    return 1
  fi

  for (( i = s; i <= e; i++ )); do
    _hastre_split_plugin_line "$lines[i]" $(( i == s )) $(( i == e ))
    for t in ${=reply[2]}; do
      if ! _hastre_valid_name "$t"; then
        print -u2 -r -- "the plugins=( array contains '$t', which is not a plain plugin name"
        return 1
      fi
    done
  done

  reply=($s $e)
}

# _hastre_edit_plugins <enable|disable> <plugin> [...]
# Rewrites .zshrc: backup to .zshrc.bak.hastre, syntax check of the result
# before it replaces the original. Returns 0 only when the file was changed.
_hastre_edit_plugins() {
  setopt localoptions noksharrays extendedglob

  local action=$1
  shift

  local zshrc=${${:-${ZDOTDIR:-$HOME}/.zshrc}:A}
  if [[ ! -f $zshrc || ! -r $zshrc || ! -w $zshrc ]]; then
    die "cannot read and write $zshrc"
    return 1
  fi

  local -a lines changed toks parts
  lines=("${(@f)$(<$zshrc)}")

  local name left right indent sindent pre c
  local -i i s e n

  for name in "$@"; do
    if ! _hastre_find_block; then
      die "can't edit $zshrc automatically, ${action} '$name' by hand"
      return 1
    fi
    s=$reply[1] e=$reply[2]

    # Every plugin name currently listed in the block
    toks=()
    for (( i = s; i <= e; i++ )); do
      _hastre_split_plugin_line "$lines[i]" $(( i == s )) $(( i == e ))
      toks+=(${=reply[2]})
    done

    if [[ $action == enable ]]; then
      if (( ${toks[(Ie)$name]} )); then
        _hastre_warn "plugin '$name' is already enabled in $zshrc"
        continue
      fi
      if (( ${plugins[(Ie)$name]} )); then
        _hastre_warn "plugin '$name' is enabled in this session but not in the plugins=( array of $zshrc, not touching it"
        continue
      fi

      # 1) a commented-out entry in the block ("  # name") is uncommented
      n=0
      for (( i = s + 1; i <= e; i++ )); do
        pre=${lines[i]%%\#*}
        [[ -z ${pre//[[:space:]]/} && $lines[i] == *\#* ]] || continue
        c=${lines[i]#*\#}
        c=${${c##[[:space:]]#}%%[[:space:]]#}
        if [[ $c == "$name" ]]; then
          lines[i]="${pre}${name}"
          n=1
          break
        fi
      done

      # 2) otherwise the name is added at the end of the block, but before
      #    zsh-syntax-highlighting, which has to be loaded last
      if (( ! n )); then
        _hastre_split_plugin_line "$lines[e]" $(( e == s )) 1
        left=$reply[1] c=$reply[2] right=$reply[3]
        if (( e == s )); then
          # one-line form: plugins=(a b) -> plugins=(a b name)
          parts=(${=c})
          if [[ $parts[-1] == zsh-syntax-highlighting ]]; then
            parts[-1,-1]=("$name" zsh-syntax-highlighting)
          else
            parts+=("$name")
          fi
          lines[e]="${left}${(j: :)parts}${right}"
        else
          # multi-line form: indent like the last entry of the block
          indent= pre=
          i=0
          for (( n = e - 1; n > s; n-- )); do
            pre=${lines[n]%%\#*}
            if [[ -n ${pre//[[:space:]]/} ]]; then
              indent=${lines[n]%%[^[:space:]]*}
              i=$n
              break
            fi
          done
          sindent=${lines[s]%%[^[:space:]]*}
          [[ -n $indent ]] || indent="$sindent  "
          if [[ -n ${c//[[:space:]]/} ]]; then
            # names share the line with the closing paren: move it down
            lines[e,e]=("${left}${c%%[[:space:]]#}" "${indent}${name}" "${sindent}${right}")
          elif (( i )) && [[ ${pre//[[:space:]]/} == zsh-syntax-highlighting ]]; then
            lines[i,i]=("${indent}${name}" "$lines[i]")
          else
            lines[e,e]=("${indent}${name}" "$lines[e]")
          fi
        fi
      fi
      changed+=("$name")
    else
      if (( ! ${toks[(Ie)$name]} )); then
        _hastre_warn "plugin '$name' is not in the plugins=( array of $zshrc"
        continue
      fi
      for (( i = s; i <= e; i++ )); do
        _hastre_split_plugin_line "$lines[i]" $(( i == s )) $(( i == e ))
        left=$reply[1] c=$reply[2] right=$reply[3]
        parts=(${=c})
        (( ${parts[(Ie)$name]} )) || continue
        parts=(${parts:#"$name"})
        if (( $#parts == 0 && i != s && i != e )); then
          # an entry on its own line is commented out, like in the template
          lines[i]="${left}# ${name}${right:+  $right}"
        else
          [[ $right == \#* && $#parts -gt 0 ]] && right=" $right"
          lines[i]="${left}${(j: :)parts}${right}"
        fi
      done
      changed+=("$name")
    fi
  done

  (( $#changed )) || return 1

  local new=$zshrc.new backup=$zshrc.bak.hastre
  if ! { command cp -p -- "$zshrc" "$new" && print -rl -- "${lines[@]}" >| "$new" } 2>/dev/null; then
    command rm -f -- "$new"
    die "could not write $new"
    return 1
  fi
  if ! command zsh -n "$new"; then
    command rm -f -- "$new"
    die "the edited file has syntax errors, $zshrc was not changed"
    return 1
  fi
  if ! { command cp -p -- "$zshrc" "$backup" && command mv -f -- "$new" "$zshrc" }; then
    command rm -f -- "$new"
    die "could not replace $zshrc"
    return 1
  fi

  _hastre_info "plugins ${action}d: ${(j:, :)changed} (backup: $backup)"
}
