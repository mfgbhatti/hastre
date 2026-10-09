# config

Core shell configuration. `hastre.zsh` sources every `config/*.zsh` file, in
alphabetical order, **after** the plugins listed in `.zshrc` have been loaded.
Drop another `*.zsh` file in here and it is picked up automatically.

| File | What it does |
| ---- | ------------ |
| `cli.zsh` | The `hastre` command (`help`, `version`, `reload`, `update`, `plugin ...`) and its completion. Modelled on `omz` from Oh My Zsh |
| `clipboard.zsh` | `clipcopy` and `clippaste`, picking the right backend for the platform (macOS, Wayland, X11, WSL, Cygwin, Termux, tmux, ...) |
| `completion.zsh` | Completion styles: menu selection, case-insensitive matching, caching in `$ZSH_CACHE_DIR`, hidden system users |
| `environment.zsh` | Environment variables and `PATH` entries that keep tools inside the XDG directories (npm, cargo, go, gnupg, nvm, Python, Java, wine, ...) |
| `functions.zsh` | Small helper functions, see below |
| `history.zsh` | History file location, sizes, options and the `history` alias |
| `key-bindings.zsh` | Emacs key bindings, history search on Up/Down, Home/End/Delete, word movement |
| `options.zsh` | Shell options: `auto_cd`, `auto_pushd`, `pushd_ignore_dups`, `pushdminus`, `correct` |

## Notes

### `environment.zsh`

It relies on the `XDG_*` variables from `~/.zshenv` (see
[`templates/zshenv`](../templates/README.md)). It also adds `~/.local/bin`
(uv tools) and the npm and cargo `bin` directories to `PATH`. Remove the
sections for tools you do not use.

### `history.zsh`

- The history file defaults to `$XDG_STATE_HOME/zsh/history`. Set `HISTFILE`
  in `.zshrc` to change it. The directory is created if needed.
- `HISTSIZE` and `SAVEHIST` are raised to at least 50000 and 10000.
- `HIST_STAMPS` controls the `history` timestamps: `mm/dd/yyyy`, `dd.mm.yyyy`,
  `yyyy-mm-dd`, any `strftime` format, or empty for none.
- `history -c` clears the history after asking for confirmation.

### `functions.zsh`

| Function | Description |
| -------- | ----------- |
| `ftext <text>` | Case-insensitive recursive search in the current directory, shown in `less` |
| `cpg`, `mvg` | `cp` / `mv`, then `cd` into the destination if it is a directory |
| `mkdirg <dir>` | `mkdir -p` and `cd` into it |
| `fkill` | Pick processes with `fzf` and kill them (SIGTERM, then SIGKILL). Needs `fzf` |
| `backup <path>` | Copy a file or directory to `<path>.backup.<timestamp>` |
| `freplace <search> <replace> <glob>` | `sed` search and replace over the matching files, with confirmation and `.bak` copies |
| `note [text]` | Append a timestamped line to `~/.notes`, or print the notes with no argument |
| `findbig [size] [dir]` | List files larger than `size` (default `100M`), biggest first |
| `checksum <file>` | Print MD5, SHA1 and SHA256 |
| `tb [file]` | Upload a file or stdin to [termbin.com](https://termbin.com). Needs `nc` |

### `clipboard.zsh`

```zsh
echo hello | clipcopy     # stdin to the clipboard
clipcopy file.txt         # a file to the clipboard
clippaste > out.txt       # clipboard to stdout
```

The first call detects the platform. If no clipboard tool is found the
functions print an error and return 1; install `xclip`, `xsel` or `wl-clipboard`
and call them again.

### `cli.zsh`

See [Commands](../README.md#commands) in the main README.

## Overriding

These files are part of the repository, so local edits will conflict with
`hastre update`. Put personal settings in `.zshrc` (settings before the
`source .../hastre.zsh` line, your own aliases and functions after it) instead.
Anything set in `.zshrc` before Hastre loads is respected where noted above
(`HISTFILE`, `HISTSIZE`, `SAVEHIST`, `HIST_STAMPS`, `ZSH_CACHE_DIR`, ...).
