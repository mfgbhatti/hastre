# Hastre

A lightweight, XDG-friendly Zsh configuration, heavily inspired by [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh).

## Credits

Hastre would not exist without **Oh My Zsh**. Much of its structure and code is adapted from it: the plugin loader, completion, history, key bindings, clipboard helpers, and several plugins (`git`, `fzf`, `uv`, `gh`, `copyfile`, `copypath`, `copybuffer`, `common-aliases`, and more). Thank you to the OMZ maintainers and contributors. Their work is MIT licensed.

Bundled third-party plugins:

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use)

## Features

- Plugin system: list names in `plugins=(...)` and Hastre loads them
- Cached, byte-compiled completion
- Sensible history, options, and key bindings
- Cross-platform clipboard (`clipcopy` / `clippaste`), including Termux
- XDG base directories, with history in `$XDG_STATE_HOME`
- Weekly workflow that checks bundled plugins for updates

## Install

```zsh
git clone https://github.com/mfgbhatti/hastre ~/.config/zsh
~/.config/zsh/tools/hastre-setup          # ~/.zshenv, .zshrc from the template, then deps check
~/.config/zsh/tools/hastre-setup deps     # just check for fzf, starship, git, ...
```

`hastre-setup` points zsh at the repo (ZDOTDIR + XDG dirs) and installs `templates/zshrc` as `.zshrc`. An existing, different `.zshrc` is backed up first. Then restart your shell.

## Configure

`.zshrc` is personal and git-ignored. Edit it to change the `plugins` array (`templates/zshrc` lists every option):

```zsh
plugins=(copyfile copypath copybuffer common-aliases fzf starship uv git gh zsh-autosuggestions zsh-syntax-highlighting)
```

Extra plugins available: `systemd`, `archlinux`, `dnf`, `you-should-use`.

## Requirements

`zsh`, `git`, `fzf`, `starship`. Optional: `bat`, `delta`, `nvim`, `curl`.

## License

[MIT](LICENSE)
