# bat plugin

Aliases and helpers for [bat](https://github.com/sharkdp/bat). Works with
both `bat` and Debian/Ubuntu's `batcat`. Does nothing if neither is installed.

To use it, add `bat` to the plugins array in your `.zshrc`:

```zsh
plugins=(... bat)
```

## Settings

| Variable        | Default      | Description                                             |
| --------------- | ------------ | ------------------------------------------------------- |
| `BAT_THEME`     | `OneHalfDark`| Theme. Your own value is respected.                     |
| `BAT_ALIAS_CAT` | unset        | Set to `1` (before loading Hastre) to alias `cat` to `bat --plain --paging=never`. |

## Aliases

| Alias | Command                       | Description                        |
| ----- | ----------------------------- | ---------------------------------- |
| `b`   | `bat`                         | Short name                         |
| `bp`  | `bat --plain`                 | No line numbers or decorations     |
| `bpp` | `bat --plain --paging=never`  | Plain, never page                  |
| `bd`  | `bat --diff`                  | Only git-modified lines            |
| `ba`  | `bat --show-all`              | Show tabs, spaces and newlines     |
| `bt`  | `bat --list-themes`           | List themes                        |
| `bL`  | `bat --list-languages`        | List languages                     |

## Functions

- `bman <page>`: colorized man page.
- `bhelp <cmd> [sub...]`: colorized `--help` output, e.g. `bhelp git commit`.
- `blog <file>`: `tail -f` with log highlighting.
- `bgd`: view uncommitted git changes with `bat --diff`.
