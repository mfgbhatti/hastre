# created goes to https://github.com/ohmyzsh/ohmyzsh
# Pacman - https://wiki.archlinux.org/index.php/Pacman_Tips
alias pupg='sudo pacman -Syu'
alias pin='sudo pacman -S'
alias plean='sudo pacman -Sc'
alias pins='sudo pacman -U'
alias plr='sudo pacman -Scc'
alias prem='sudo pacman -Rns'
alias prep='pacman -Si'
alias preps='pacman -Ss'
alias ploc='pacman -Qi'
alias plocs='pacman -Qs'
alias pinsd='sudo pacman -S --asdeps'
alias pmir='sudo pacman -Syy'
alias plsorphans='pacman -Qdt'
alias prmorphans='sudo pacman -Rs $(pacman -Qtdq)'
alias pfileupg='sudo pacman -Fy'
alias pfiles='pacman -F'
alias pls='pacman -Ql'
alias pown='pacman -Qo'
alias pupd="sudo pacman -Sy"

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

  find /etc /usr ! -name lost+found \
    \( -type d -printf '%p/\n' -o -print \) | sort > "$fs"

  comm -23 "$fs" "$db"

  rm -rf $tmp_dir
}

alias pacmanallkeys='sudo pacman-key --refresh-keys'

function pacmansignkeys() {
  local key
  for key in $@; do
    sudo pacman-key --recv-keys $key
    sudo pacman-key --lsign-key $key
    printf 'trust\n3\n' | sudo gpg --homedir /etc/pacman.d/gnupg \
      --no-permission-warning --command-fd 0 --edit-key $key
  done
}

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

# Check Arch Linux PGP Keyring before System Upgrade to prevent failure.
function upgrade() {
  sudo pacman -Sy
  echo ":: Checking Arch Linux PGP Keyring..."
  local installedver="$(LANG= sudo pacman -Qi archlinux-keyring | grep -Po '(?<=Version         : ).*')"
  local currentver="$(LANG= sudo pacman -Si archlinux-keyring | grep -Po '(?<=Version         : ).*')"
  if [ $installedver != $currentver ]; then
    echo " Arch Linux PGP Keyring is out of date."
    echo " Updating before full system upgrade."
    sudo pacman -S --needed --noconfirm archlinux-keyring
  else
    echo " Arch Linux PGP Keyring is up to date."
    echo " Proceeding with full system upgrade."
  fi
  if (( $+commands[yay] )); then
    yay -Su
  elif (( $+commands[trizen] )); then
    trizen -Su
  elif (( $+commands[pacaur] )); then
    pacaur -Su
  elif (( $+commands[aura] )); then
    sudo aura -Su
  else
    sudo pacman -Su
  fi
}
