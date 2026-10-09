# templates

Starting points for the two personal files Hastre needs outside the repo
checkout. [`tools/hastre-setup`](../tools/README.md) copies them into place;
you can also copy them by hand.

| Template | Installed as | Purpose |
| -------- | ------------ | ------- |
| `zshenv` | `~/.zshenv` | Defines the XDG base directories and points zsh at Hastre with `ZDOTDIR` |
| `zshrc` | `~/.config/zsh/.zshrc` | Chooses plugins and settings, then loads Hastre |

## zshenv

zsh reads `~/.zshenv` for every invocation, including scripts, so the file
holds variables only: no `PATH` changes, no commands, no aliases. Those go in
`config/environment.zsh`.

It sets `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME` and
`XDG_STATE_HOME` (keeping any value that is already set) and then
`ZDOTDIR="$XDG_CONFIG_HOME/zsh"`. zsh then reads `.zshrc` from the checkout
instead of `$HOME`.

## zshrc

The installed `.zshrc` is **personal and git-ignored**, so `hastre update`
never overwrites it. The template is where new options and plugins are
documented, so compare against it after an update:

```zsh
diff ~/.config/zsh/templates/zshrc ~/.config/zsh/.zshrc
```

It is split into:

- **Core and history settings**: `ZSH`, `ZSH_CACHE_DIR`, `ZSH_COMPDUMP`,
  `HIST_STAMPS`, `HISTFILE`, `HISTSIZE`, `SAVEHIST`.
- **`plugins=( ... )`**: the plugins to load. Plugins that are not on by
  default are commented out; `hastre plugin enable <name>` and
  `hastre plugin disable <name>` toggle those lines.
- **Plugin settings**: `bat`, `zsh-autosuggestions`, `zsh-syntax-highlighting`,
  `you-should-use` and `fzf` options, commented out.
- **`source .../hastre.zsh`**: loads Hastre. Every setting above must come
  before this line.
- Your own aliases, exports and functions go below it.

If a different `.zshrc` already exists, `hastre-setup zshrc` backs it up as
`.zshrc.bak.<timestamp>` before installing the template.
