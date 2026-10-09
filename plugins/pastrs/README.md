# pastrs plugin

Upload text to [paste.rs](https://paste.rs) from the command line and get a
shareable URL back. Provides one function, `paste_rs`. Requires `curl`; the
plugin does nothing if it is not installed.

To use it, add `pastrs` to the plugins array in your `.zshrc`:

```zsh
plugins=(... pastrs)
```

## Usage

```zsh
paste_rs [FILE]
echo 'text' | paste_rs
paste_rs -d ID_OR_URL
```

With no `FILE`, `paste_rs` reads from stdin. The paste URL is printed on
success.

| Option              | Description                                      |
| ------------------- | ------------------------------------------------ |
| `-h`, `--help`      | Show the built-in help                           |
| `-d`, `--delete ID` | Delete a paste. Accepts the ID or the full URL.  |

## Examples

```zsh
# Paste a file
paste_rs notes.txt

# Paste command output
git diff | paste_rs

# Delete a paste (an ID, a URL, or a URL with an extension all work)
paste_rs -d https://paste.rs/abcd
```

## Rendering

paste.rs serves pastes as plain text. Add a file extension to the returned URL
to change how it is displayed:

- `.md` renders Markdown as HTML.
- Language extensions such as `.py` or `.js` give syntax highlighting.

## Notes

- Pastes are public: anyone with the URL can read them. Don't paste secrets.
- paste.rs rate limits pasting heavily, and truncates pastes over its size
  limit. A truncated paste (HTTP 206) still prints its URL, with a warning on
  stderr.
- Any other HTTP error is printed on stderr and `paste_rs` returns 1, so it is
  safe to use in scripts: `url=$(paste_rs file.txt) || echo failed`.
- `paste_rs` also returns 1 for a missing or unreadable `FILE`, an unknown
  option, or more than one `FILE`.
