# tools

Standalone zsh scripts for installing and releasing Hastre. Nothing here runs
at shell startup; run them by hand. All of them support `-n`/`--dry-run` and
`-y`/`--yes`, and are safe to run more than once.

## hastre-setup

Sets up a fresh checkout. Run it after cloning to `~/.config/zsh`:

```zsh
~/.config/zsh/tools/hastre-setup            # zshenv, then zshrc, then deps
~/.config/zsh/tools/hastre-setup zshenv [--force]
~/.config/zsh/tools/hastre-setup zshrc
~/.config/zsh/tools/hastre-setup deps [--install]
```

| Step | What it does |
| ---- | ------------ |
| `zshenv` | Makes sure `~/.zshenv` sets `ZDOTDIR` to this repo and defines the `XDG_*` directories. A missing file is created from [`templates/zshenv`](../templates/README.md). A working file is left alone. A file that does not work is reported and left unchanged, unless `--force` is given: then it is backed up to `~/.zshenv.bak.<timestamp>` and replaced |
| `zshrc` | Installs [`templates/zshrc`](../templates/README.md) as `$ZDOTDIR/.zshrc`. An identical file is left alone; a different one is backed up to `.zshrc.bak.<timestamp>` first, after asking |
| `deps` | Reports which programs Hastre uses are installed: `git`, `fzf` and `starship` are required; `nvim`, `bat`, `delta`, `nc` and `curl` are optional. With `--install` it offers to install missing ones with `pkg`, `apt`, `pacman` or `dnf` |

| Option | Description |
| ------ | ----------- |
| `-n`, `--dry-run` | Show what would happen, change nothing |
| `-y`, `--yes` | Do not ask for confirmation |
| `-h`, `--help` | Show the built-in help |

Exit status: `0` all good, `1` something needs attention, `2` usage error.

The repository must live at `$XDG_CONFIG_HOME/zsh` (usually `~/.config/zsh`),
because the `zshenv` template points `ZDOTDIR` there.

## hastre-version

Shows, bumps or sets the version stored in the [`VERSION`](../VERSION) file.

```zsh
tools/hastre-version                      # same as: show
tools/hastre-version bump patch           # 0.3.3 -> 0.3.4
tools/hastre-version bump minor|major
tools/hastre-version set 1.0.0
```

A release is one commit that changes `VERSION`, plus an annotated tag
`vX.Y.Z`. Nothing is pushed. Before writing anything it checks that:

- the directory is a git repository, on a branch (not a detached `HEAD`)
- the working tree is clean
- the target tag does not already exist

Use `--dry-run` to see what would happen first.
