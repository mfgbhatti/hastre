# created goes to https://github.com/ohmyzsh/ohmyzsh
# Pacman - https://wiki.archlinux.org/index.php/Pacman_Tips

# Not a pacman system (e.g. Termux using pkg/apt): define nothing.
(( $+commands[pacman] )) || return 0

# Privilege prefix, resolved once. Empty on Termux (no root, no sudo) and when
# already root; otherwise sudo, falling back to doas. It is an array so that an
# empty value disappears when expanded as `$_pac_su pacman ...`.
typeset -ga _pac_su
if [[ $OSTYPE == linux-android* ]] || (( EUID == 0 )); then
  _pac_su=()
elif (( $+commands[sudo] )); then
  _pac_su=(sudo)
elif (( $+commands[doas] )); then
  _pac_su=(doas)
fi

# Filesystem root of the pacman install: / on Arch, $PREFIX on Termux.
typeset -g _pac_root=""
if [[ $OSTYPE == linux-android* ]]; then
  _pac_root=${PREFIX:-/data/data/com.termux/files/usr}
fi

# Aliases: double quotes bake the prefix in at load time. With an empty prefix
# an alias body just gets a harmless leading space.
alias pupg="${_pac_su[*]} pacman -Syu"
alias pin="${_pac_su[*]} pacman -S"
alias plean="${_pac_su[*]} pacman -Sc"
alias pins="${_pac_su[*]} pacman -U"
alias plr="${_pac_su[*]} pacman -Scc"
alias prem="${_pac_su[*]} pacman -Rns"
alias prep='pacman -Si'
alias preps='pacman -Ss'
alias ploc='pacman -Qi'
alias plocs='pacman -Qs'
alias pinsd="${_pac_su[*]} pacman -S --asdeps"
alias pmir="${_pac_su[*]} pacman -Syy"
alias plsorphans='pacman -Qdt'
alias prmorphans="${_pac_su[*]} pacman -Rs \$(pacman -Qtdq)"
alias pfileupg="${_pac_su[*]} pacman -Fy"
alias pfiles='pacman -F'
alias pls='pacman -Ql'
alias pown='pacman -Qo'
alias pupd="${_pac_su[*]} pacman -Sy"

function paclist() {
  pacman -Qqe | xargs -I{} -P0 --no-run-if-empty pacman -Qs --color=auto "^{}\$"
}

function pacdisowned() {
  local tmp_dir db fs
  tmp_dir=$(mktemp --directory)
  db=$tmp_dir/db
  fs=$tmp_dir/fs

  trap "rm -rf $tmp_dir" EXIT

  pacman -Qlq | sort -u > "$db"

  # Directories pacman owns files in: /etc and /usr on Arch, $PREFIX on Termux.
  local -a roots
  if [[ -n $_pac_root ]]; then
    roots=($_pac_root)
  else
    roots=(/etc /usr)
  fi

  find $roots ! -name lost+found \
    \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

  comm -23 "$fs" "$db"

  rm -rf $tmp_dir
}

# Keyring helpers: only meaningful where pacman-key exists.
if (( $+commands[pacman-key] )); then
  alias pacmanallkeys="${_pac_su[*]} pacman-key --refresh-keys"

  function pacmansignkeys() {
    local key
    for key in $@; do
      $_pac_su pacman-key --recv-keys $key
      $_pac_su pacman-key --lsign-key $key
      printf 'trust\n3\n' | $_pac_su gpg --homedir $_pac_root/etc/pacman.d/gnupg \
        --no-permission-warning --command-fd 0 --edit-key $key
    done
  }
fi

#######################################
#             AUR helpers             #
#######################################

if (( $+commands[yay] )); then
  alias yaconf='yay -Pg'
  alias yaclean='yay -Sc'
  alias yaclr='yay -Scc'
  alias yaupg='yay -Syu'
  alias yasu='yay -Syu --noconfirm'
  alias yain='yay -S'
  alias yains='yay -U'
  alias yare='yay -R'
  alias yarem='yay -Rns'
  alias yarep='yay -Si'
  alias yareps='yay -Ss'
  alias yaloc='yay -Qi'
  alias yalocs='yay -Qs'
  alias yalst='yay -Qe'
  alias yaorph='yay -Qtd'
  alias yainsd='yay -S --asdeps'
  alias yamir='yay -Syy'
  alias yaupd="yay -Sy"
fi

# On Arch, check the PGP keyring before a system upgrade to prevent failure.
# The keyring step is skipped elsewhere (e.g. Termux).
function upgrade() {
  $_pac_su pacman -Sy
  if [[ -r /etc/arch-release ]]; then
    echo ":: Checking Arch Linux PGP Keyring..."
    local installedver="$(LANG= $_pac_su pacman -Qi archlinux-keyring | grep -Po '(?<=Version         : ).*')"
    local currentver="$(LANG= $_pac_su pacman -Si archlinux-keyring | grep -Po '(?<=Version         : ).*')"
    if [ $installedver != $currentver ]; then
      echo " Arch Linux PGP Keyring is out of date."
      echo " Updating before full system upgrade."
      $_pac_su pacman -S --needed --noconfirm archlinux-keyring
    else
      echo " Arch Linux PGP Keyring is up to date."
      echo " Proceeding with full system upgrade."
    fi
  fi
  if (( $+commands[yay] )); then
    yay -Su
  elif (( $+commands[trizen] )); then
    trizen -Su
  elif (( $+commands[pacaur] )); then
    pacaur -Su
  elif (( $+commands[aura] )); then
    $_pac_su aura -Su
  else
    $_pac_su pacman -Su
  fi
}
