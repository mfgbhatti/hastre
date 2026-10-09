# plugins

Each plugin lives in `plugins/<name>/`. List the names you want in the
`plugins=(...)` array in `.zshrc` and Hastre loads them in that order.

```zsh
plugins=(git fzf starship zsh-autosuggestions zsh-syntax-highlighting)
```

Manage them with the `hastre` command:

```zsh
hastre plugin list [--enabled]
hastre plugin info <plugin>      # show the plugin's README
hastre plugin load <plugin> ...  # this session only
hastre plugin enable <plugin> ...
hastre plugin disable <plugin> ...
```

The full list of plugins, with a one-line description of each, is in the
[main README](../README.md#plugins). `templates/zshrc` lists them too, with
the ones that are not on by default commented out.

## How loading works

1. For every name in `plugins`, `hastre.zsh` checks that the plugin exists
   (see below) and adds `plugins/<name>/` to `fpath`. An unknown name prints
   `[error] plugin '<name>' not found`.
2. `compinit` runs, so completion files (`_name`) in those directories are
   found.
3. `plugins/<name>/<name>.plugin.zsh` is sourced for each plugin, in the order
   given.
4. `config/*.zsh` is sourced afterwards.

Because of step 4, the files in `config/` can override anything a plugin
sets. Load `zsh-syntax-highlighting` last.

## Layout of a plugin

```
plugins/<name>/
├── <name>.plugin.zsh   # sourced when the plugin is loaded
├── _<name>             # optional: completion function
└── README.md           # optional: shown by `hastre plugin info <name>`
```

A directory counts as a plugin if it has either `<name>.plugin.zsh` or a
`_<name>` completion file. A plugin with only a completion file is added to
`fpath` but nothing is sourced.

## Adding a plugin

1. Create `plugins/<name>/<name>.plugin.zsh`. The name must contain only
   letters, digits and `_ . + -`.
2. Add a `README.md` with the commands or aliases it provides and any
   requirements.
3. Add it to the plugin table in the main README and to the `plugins=(...)`
   list in `templates/zshrc` (commented out unless it should be on by default).
4. Enable it with `hastre plugin enable <name>` or by editing `.zshrc`.

Plugins that need an external program should check for it and do nothing when
it is missing, so a fresh machine does not print errors at startup:

```zsh
(( $+commands[curl] )) || return
```

## Bundled third-party plugins

These are copies of upstream projects and keep their own licence and
documentation. Do not edit them here; the weekly dependency workflow checks
them for updates.

| Plugin | Upstream |
| ------ | -------- |
| `fzf-tab` | [Aloxaf/fzf-tab](https://github.com/Aloxaf/fzf-tab) |
| `you-should-use` | [MichaelAquilina/zsh-you-should-use](https://github.com/MichaelAquilina/zsh-you-should-use) |
| `zsh-autosuggestions` | [zsh-users/zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) |
| `zsh-syntax-highlighting` | [zsh-users/zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) |

All other plugins are Hastre's own, many adapted from Oh My Zsh.
