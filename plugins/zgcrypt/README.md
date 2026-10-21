# zgcrypt plugin

Encrypt and decrypt a directory with `tar`, `zstd` and `gpg`. The data is
streamed through all three, so no unencrypted archive is written to disk. Does
nothing if any of the three is not installed.

To use it, add `zgcrypt` to the plugins array in your `.zshrc`:

```zsh
plugins=(... zgcrypt)
```

Encrypting asks for a passphrase twice (AES256). Decrypting asks once. The
passphrase is read from the terminal and passed to gpg through a file
descriptor, so it never appears in the process list. This also avoids the
`Inappropriate ioctl for device` pinentry error in Termux.

## Settings

| Variable                | Default | Description                                              |
| ----------------------- | ------- | -------------------------------------------------------- |
| `ZGCRYPT_ZSTD_LEVEL`    | `19`    | zstd compression level                                   |
| `ZGCRYPT_ZSTD_THREADS`  | `0`     | zstd threads (0 = all cores)                             |
| `ZGCRYPT_GPG_RECIPIENT` | unset   | Encrypt to this public key instead of using a passphrase |

## Commands

| Command                               | Description                                  |
| ------------------------------------- | -------------------------------------------- |
| `zgcrypt encrypt <dir> [output]`      | Create `<dir>.tar.zst.gpg` (or `output`)     |
| `zgcrypt decrypt <file> [output_dir]` | Extract into `output_dir` (default `.`)      |

## Aliases

| Alias   | Command            |
| ------- | ------------------ |
| `zgenc` | `zgcrypt encrypt`  |
| `zgdec` | `zgcrypt decrypt`  |

## Completion

`_zgcrypt` completes the subcommands, directories for `encrypt` and `*.gpg`
files for `decrypt`.
