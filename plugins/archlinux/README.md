# Arch Linux plugin

This plugin adds aliases and functions for working with pacman, on Arch Linux
and on Termux's pacman variant.

To use it, add `archlinux` to the plugins array in your zshrc file:

```zsh
plugins=(... archlinux)
```

If `pacman` is not installed (for example Termux using `pkg`/apt), the plugin
loads nothing.

## Privilege prefix

Commands that change the system run through a prefix chosen once, when the
plugin loads:

| Situation                          | Prefix |
|------------------------------------|--------|
| Termux (no root, no sudo)          | none   |
| Already root                       | none   |
| `sudo` installed                   | `sudo` |
| No `sudo`, but `doas` is installed | `doas` |

The tables below show `sudo`; read it as "the prefix above".

## Features

### Pacman

| Alias       | Command                       | Description                                                  |
|-------------|-------------------------------|--------------------------------------------------------------|
| pin         | `sudo pacman -S`              | Install packages from the repositories                       |
| pins        | `sudo pacman -U`              | Install a package from a local file                          |
| pinsd       | `sudo pacman -S --asdeps`     | Install packages as dependencies of another package          |
| plean       | `sudo pacman -Sc`             | Clean out old and unused caches and packages                 |
| plr         | `sudo pacman -Scc`            | Remove all files from the cache                              |
| ploc        | `pacman -Qi`                  | Display information about a package in the local database    |
| plocs       | `pacman -Qs`                  | Search for packages in the local database                    |
| plsorphans  | `pacman -Qdt`                 | List all orphaned packages                                   |
| pmir        | `sudo pacman -Syy`            | Force refresh of all package lists after updating mirrorlist |
| prem        | `sudo pacman -Rns`            | Remove packages, including settings and dependencies         |
| prep        | `pacman -Si`                  | Display information about a package in the repositories      |
| preps       | `pacman -Ss`                  | Search for packages in the repositories                      |
| prmorphans  | `sudo pacman -Rs $(pacman -Qtdq)` | Delete all orphaned packages                             |
| pupd        | `sudo pacman -Sy`             | Refresh the package databases                                |
| pupg        | `sudo pacman -Syu`            | Sync with repositories before upgrading packages             |
| pfileupg    | `sudo pacman -Fy`             | Download fresh package file databases from the server        |
| pfiles      | `pacman -F`                   | Search package file names for matching strings               |
| pls         | `pacman -Ql`                  | List files in a package                                      |
| pown        | `pacman -Qo`                  | Show which package owns a file                               |

| Function       | Description                                               |
|----------------|-----------------------------------------------------------|
| upgrade        | Upgrade the system, see [Upgrade](#upgrade)               |
| paclist        | List all explicitly installed packages with a description |
| pacdisowned    | List files under the pacman root that no package owns     |
| pacmansignkeys | Locally trust all keys passed as parameters               |

| Alias         | Command                        | Description                              |
|---------------|--------------------------------|------------------------------------------|
| pacmanallkeys | `sudo pacman-key --refresh-keys` | Refresh the keys of all trusted keyrings |

`pacmansignkeys` and `pacmanallkeys` are only defined when `pacman-key` is
installed.

### AUR helpers

Defined only when `yay` is installed.

| Alias   | Command                 | Description                                                       |
|---------|-------------------------|-------------------------------------------------------------------|
| yaconf  | `yay -Pg`               | Print current configuration                                       |
| yaclean | `yay -Sc`               | Clean out old and unused caches and packages                      |
| yaclr   | `yay -Scc`              | Remove all files from the cache                                   |
| yain    | `yay -S`                | Install packages from the repositories and the AUR                |
| yains   | `yay -U`                | Install a package from a local file                               |
| yainsd  | `yay -S --asdeps`       | Install packages as dependencies of another package               |
| yaloc   | `yay -Qi`               | Display information about a package in the local database         |
| yalocs  | `yay -Qs`               | Search for packages in the local database                         |
| yalst   | `yay -Qe`               | List explicitly installed packages, including from the AUR        |
| yamir   | `yay -Syy`              | Force refresh of all package lists after updating mirrorlist      |
| yaorph  | `yay -Qtd`              | List orphaned packages                                            |
| yare    | `yay -R`                | Remove packages, keeping settings and dependencies                |
| yarem   | `yay -Rns`              | Remove packages, including settings and unneeded dependencies     |
| yarep   | `yay -Si`               | Display information about a package in the repositories           |
| yareps  | `yay -Ss`               | Search for packages in the repositories                           |
| yaupd   | `yay -Sy`               | Refresh the package databases                                     |
| yaupg   | `yay -Syu`              | Sync with repositories before upgrading packages                  |
| yasu    | `yay -Syu --noconfirm`  | Same as `yaupg`, but without confirmation                         |

### Upgrade

`upgrade` refreshes the databases, then upgrades with the first AUR helper
found, in this order:

1. `yay`
2. `trizen`
3. `pacaur`
4. `aura`
5. plain `pacman -Su`

On Arch Linux it first checks the PGP keyring and updates `archlinux-keyring`
when it is out of date, to prevent signature failures during the upgrade. That
check is skipped on other systems, including Termux.

## Termux

Termux ships two package managers. This plugin is for the pacman variant of
Termux; with the default `pkg`/apt setup it does nothing.

On Termux:

- There is no root and no `sudo`, so commands run without a prefix.
- `upgrade` skips the Arch keyring check and has no AUR helpers to try, so it
  runs a plain `pacman -Su`.
- `pacdisowned` scans `$PREFIX` instead of `/etc` and `/usr`, and
  `pacmansignkeys` uses the keyring under `$PREFIX/etc/pacman.d/gnupg`.
- Termux is detected from `$OSTYPE` (`linux-android*`), the same check used
  elsewhere in this repo.

## Contributors

- Benjamin Boudreau - dreurmail@gmail.com
- Celso Miranda - contacto@celsomiranda.net
- ratijas (ivan tkachenko) - me@ratijas.tk
- Juraj Fiala - doctorjellyface@riseup.net
- KhasMek - Boushh@gmail.com
- Majora320 (Moses Miller) - Majora320@gmail.com
- Martin Putniorz - mputniorz@gmail.com
- MatthR3D - matthr3d@gmail.com
- ornicar - thibault.duplessis@gmail.com
- Ybalrid (Arthur Brainville) - ybalrid@ybalrid.info
- Jeff M. Hubbard - jeffmhubbard@gmail.com
- K. Harishankar(harishnkr) - hari2menon1234@gmail.com
- WH-2099 - wh2099@outlook.com
