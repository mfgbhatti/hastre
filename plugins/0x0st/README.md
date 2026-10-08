# 0x0st plugin

Upload files to [0x0.st](https://0x0.st) from the command line and get a URL
back. Provides one function, `0x0_st` (note the underscore; the plugin
directory is `0x0st`). Requires `curl`; the plugin does nothing if it is not
installed.

To use it, add `0x0st` to the plugins array in your `.zshrc`:

```zsh
plugins=(... 0x0st)
```

> **Service status:** as of April 2026, 0x0.st had disabled uploads. The server
> replied that it was overwhelmed by automated spam and would return with
> changes at some point, with no ETA. If uploads are still off, `0x0_st` prints
> the server's message on stderr and returns 1.

## Usage

```zsh
0x0_st [-s] [-e EXPIRES] FILE
echo 'text' | 0x0_st [-s] [-e EXPIRES]
0x0_st -u URL
0x0_st -d TOKEN URL
```

With no `FILE`, `0x0_st` reads from stdin (uploaded as `stdin.txt`).

| Option                  | Description                                                    |
| ----------------------- | -------------------------------------------------------------- |
| `-h`, `--help`          | Show the built-in help                                         |
| `-s`, `--secret`        | Use a longer, hard-to-guess URL                                |
| `-e`, `--expires N`     | Keep for `N` hours, or until a Unix timestamp in ms (a number) |
| `-u`, `--url URL`       | Have 0x0.st fetch a remote URL instead of uploading a file     |
| `-d`, `--delete TOKEN URL` | Delete an upload using the token from when it was uploaded |

## Examples

```zsh
# Upload a file
0x0_st file.png

# Hard-to-guess URL, deleted after 24 hours
0x0_st -s -e 24 notes.txt

# Upload command output
dmesg | 0x0_st

# Let 0x0.st fetch a remote file
0x0_st -u https://example.com/image.jpg

# Delete an upload, using the token printed when you uploaded it
0x0_st -d TOKEN https://0x0.st/abcd.png
```

## Management token

After each upload, the server's `X-Token` and `X-Expires` headers are printed
to **stderr**, after the URL (which goes to stdout). Keep the token if you may want to
delete the upload before it expires. Because they are on stderr, they stay out
of the way when you pipe or capture the URL:

```zsh
url=$(0x0_st file.png)    # token and expiry still show in the terminal
```

## Notes

- Uploads are public to anyone with the URL. Use `-s` to make it hard to guess,
  and don't upload secrets.
- If the server answers with an HTTP error, its message is printed on stderr
  and `0x0_st` returns 1, so it is safe to use in scripts:
  `url=$(0x0_st file.png) || echo failed`.
- `0x0_st` also returns 1 for a missing or unreadable `FILE`, an unknown
  option, a missing or non-numeric value for `-e`, more than one `FILE`, or
  `-u` combined with a `FILE`.
- File names containing `;` or `,` are supported.
