# fail2ban: helpers for fail2ban-client.
# https://github.com/fail2ban/fail2ban
#
# fail2ban-client talks to a root-owned socket, so everything here runs
# through sudo unless you are already root. Completion for fail2ban-client
# comes from the `_fail2ban` file in this directory.

(( ${+commands[fail2ban-client]} )) || return

# Run a command as root: directly if already root, otherwise via sudo.
function _f2b_root {
  if (( EUID == 0 )); then
    "$@"
  elif (( ${+commands[sudo]} )); then
    sudo "$@"
  else
    print -u2 "fail2ban: need root or sudo"
    return 1
  fi
}

# fail2ban-client as root: f2b status sshd
function f2b {
  _f2b_root fail2ban-client "$@"
}

# Completion for the wrapper is the same as for fail2ban-client.
(( ${+functions[compdef]} )) && compdef f2b=fail2ban-client

alias f2bping='f2b ping'
alias f2breload='f2b reload'
alias f2btest='f2b -t'          # check the configuration

# List the names of all active jails, one per line: f2bjails
function f2bjails {
  emulate -L zsh
  local out list
  out=$(f2b status) || return
  list=${${(M)${(f)out}:#*Jail list*}#*:}
  list=${list//[[:space:]]/}
  [[ -n $list ]] && print -rl -- ${(s:,:)list}
  return 0
}

# One-line summary per jail (failed / banned now / banned in total).
# All jails by default: f2bstatus [jail...]
function f2bstatus {
  emulate -L zsh
  local -a jails
  jails=("$@")
  (( $# )) || jails=(${(f)"$(f2bjails)"})
  (( ${#jails} )) || { print -u2 "f2bstatus: no jails found"; return 1 }

  local j out
  {
    print "JAIL\tFAILED\tBANNED\tTOTAL"
    for j in $jails; do
      out=$(f2b status $j) || continue
      print -r -- "$out" | awk -F: -v jail=$j '
        function v(s) { gsub(/[[:space:]]/, "", s); return s }
        /Currently failed/ { f = v($2) }
        /Currently banned/ { b = v($2) }
        /Total banned/     { t = v($2) }
        END { printf "%s\t%s\t%s\t%s\n", jail, f, b, t }'
    done
  } | if (( ${+commands[column]} )); then column -t -s $'\t'; else cat; fi
}

# Print currently banned addresses as "jail ip", one per line.
# All jails by default: f2bbanned [jail...]
function f2bbanned {
  emulate -L zsh
  local -a jails
  jails=("$@")
  (( $# )) || jails=(${(f)"$(f2bjails)"})

  local j out ips ip
  for j in $jails; do
    out=$(f2b status $j) || continue
    ips=${${(M)${(f)out}:#*Banned IP list*}#*:}
    for ip in ${=ips}; do
      print -r -- "$j $ip"
    done
  done
}

# Ban an address in a jail: f2bban sshd 203.0.113.7
function f2bban {
  emulate -L zsh
  (( $# == 2 )) || { print -u2 "Usage: f2bban <jail> <ip>"; return 1 }
  f2b set $1 banip $2
}

# Unban an address, in every jail or only in one: f2bunban 203.0.113.7 [jail]
function f2bunban {
  emulate -L zsh
  case $# in
    1) f2b unban $1 ;;
    2) f2b set $2 unbanip $1 ;;
    *) print -u2 "Usage: f2bunban <ip> [jail]"; return 1 ;;
  esac
}

# Follow the fail2ban log, last N lines first (default 50): f2blog [N]
# Uses /var/log/fail2ban.log, or the journal when that file does not exist.
function f2blog {
  emulate -L zsh
  local n=${1:-50} log=/var/log/fail2ban.log
  if [[ -e $log ]]; then
    _f2b_root tail -n $n -f -- $log
  else
    _f2b_root journalctl -u fail2ban -n $n -f
  fi
}
