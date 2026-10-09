# Hastre

A lightweight, XDG-friendly Zsh configuration, heavily inspired by [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh).

## Credits

Hastre would not exist without **Oh My Zsh**. Much of its structure and code is adapted from it: the plugin loader, completion, history, key bindings, clipboard helpers, and several plugins (`git`, `fzf`, `uv`, `gh`, `npm`, `rust`, `extract`, `copyfile`, `copypath`, `copybuffer`, `common-aliases`, and more). Thank you to the OMZ maintainers and contributors. Their work is MIT licensed.

Bundled third-party plugins:

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use)
- [fzf-tab](https://github.com/aloxaf/fzf-tab)

## Features

- Plugin system: list names in `plugins=(...)` and Hastre loads them
- Cached, byte-compiled completion
- Sensible history, options, and key bindings
- Cross-platform clipboard (`clipcopy` / `clippaste`), including Termux
- XDG base directories, with history in `$XDG_STATE_HOME`
- Bundled plugins for git, npm, rust, archives, uploads, fail2ban and more
- Weekly workflow that checks bundled plugins for updates

## Layout

```
hastre.zsh    entry point: sets up fpath, completion, loads plugins and config
config/       core settings, functions and the `hastre` command
plugins/      bundled plugins, one directory each
templates/    zshenv and zshrc templates installed by hastre-setup
tools/        hastre-setup (install) and hastre-version (releases)
VERSION       current version
```

Each directory has its own README: [config](config/README.md), [plugins](plugins/README.md), [templates](templates/README.md), [tools](tools/README.md).

## Install

```zsh
git clone https://github.com/mfgbhatti/hastre ~/.config/zsh
~/.config/zsh/tools/hastre-setup          # ~/.zshenv, .zshrc from the template, then deps check
~/.config/zsh/tools/hastre-setup deps     # just check for fzf, starship, git, ...
```

`hastre-setup` points zsh at the repo (ZDOTDIR + XDG dirs) and installs `templates/zshrc` as `.zshrc`. An existing, different `.zshrc` is backed up first. Then restart your shell. See [tools](tools/README.md) for all options, and for `hastre-version`, which bumps `VERSION` and tags a release.

## Commands

Once Hastre is loaded you get a `hastre` command (`config/cli.zsh`, modelled on `omz` from Oh My Zsh):

```zsh
hastre help
hastre version
hastre update [--check]            # git checkouts only, fast-forward
hastre reload                      # clear the completion dump, restart zsh
hastre plugin list [--enabled]
hastre plugin info <plugin>        # show the plugin README
hastre plugin load <plugin> ...    # this session only
hastre plugin enable <plugin> ...  # edit plugins=(...) in .zshrc
hastre plugin disable <plugin> ...
```

- `hastre` lives in [`config/cli.zsh`](config/README.md); the other files in `config/` are described there too.
- `update` needs `$ZSH` to be a git checkout (it has a `.git`). It stays on your current branch, only fast-forwards, and stops if tracked files have local changes. `--check` just lists new commits.
- `plugin enable` and `plugin disable` only edit a plain `plugins=( ... )` array: one assignment, plugin names only, on one line or one per line. They uncomment or comment out an entry in place, keep the old file as `.zshrc.bak.hastre`, check the syntax before replacing it, and otherwise refuse and leave your `.zshrc` alone.

## Configure

`.zshrc` is personal and git-ignored. Edit it to change the `plugins` array ([`templates/zshrc`](templates/README.md) lists every option):

```zsh
plugins=(copyfile copypath copybuffer common-aliases fzf starship uv git gh bat zsh-autosuggestions zsh-syntax-highlighting)
```

## Plugins

Each plugin lives in `plugins/<name>/` and has its own README (the bundled third-party ones keep their upstream docs). How plugins are loaded, and how to add one, is covered in [plugins](plugins/README.md). `templates/zshrc` lists them all; the ones not enabled by default are commented out.

| Plugin | Description |
| ------ | ----------- |
| `0x0st` | Upload files to 0x0.st (`0x0_st`). Needs `curl` |
| `archlinux` | Pacman and AUR helper aliases |
| `bat` | Aliases and helpers for `bat` (`bman`, `bhelp`, `blog`, `bgd`) |
| `common-aliases` | Everyday shell aliases |
| `copybuffer` | Copy the current command line to the clipboard |
| `copyfile` | Copy a file's contents to the clipboard |
| `copypath` | Copy a path to the clipboard |
| `dnf` | DNF aliases and completion |
| `extract` | `extract` any archive, whatever the format |
| `fail2ban` | `fail2ban-client` wrapper, shortcuts and completion |
| `fzf` | fzf key bindings and completion |
| `fzf-tab` | fzf-powered tab completion |
| `gh` | GitHub CLI completion |
| `git` | Git aliases and helpers |
| `npm` | npm aliases, completion and an install/uninstall toggle |
| `pastrs` | Upload text to paste.rs (`paste_rs`). Needs `curl` |
| `rust` | Completion for `rustc`, `rustup` and `cargo` |
| `starship` | Starship prompt |
| `systemd` | systemctl and journalctl aliases |
| `uv` | uv aliases and completion |
| `you-should-use` | Reminds you of aliases you could have used |
| `zsh-autosuggestions` | Fish-style suggestions as you type |
| `zsh-syntax-highlighting` | Syntax highlighting on the command line (load last) |

## Requirements

`zsh`, `git`, `fzf`, `starship`. Optional: `bat`, `delta`, `nvim`, `curl`.

## License

[MIT](LICENSE)
