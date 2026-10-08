# fail2ban plugin

Helpers for [fail2ban](https://github.com/fail2ban/fail2ban): a `sudo` wrapper
for `fail2ban-client`, shortcuts for the common tasks, and completion. Does
nothing if `fail2ban-client` is not installed.

To use it, add `fail2ban` to the plugins array in your `.zshrc`:

```zsh
plugins=(... fail2ban)
```

`fail2ban-client` talks to a root-owned socket, so every command here runs
through `sudo`, or directly if you are already root.

## Completion

The `_fail2ban` file in this directory completes `fail2ban-client` (from
[zsh-users/zsh-completions](https://github.com/zsh-users/zsh-completions)). The
`f2b` wrapper below uses the same completion.

## Aliases

| Alias        | Command           | Description                |
| ------------ | ----------------- | -------------------------- |
| `f2bping`    | `f2b ping`        | Check the server responds  |
| `f2breload`  | `f2b reload`      | Reload the configuration   |
| `f2btest`    | `f2b -t`          | Test the configuration     |

## Functions

| Function                       | Description                                                     |
| ------------------------------ | --------------------------------------------------------------- |
| `f2b <args>`                   | `fail2ban-client <args>` as root, e.g. `f2b status sshd`        |
| `f2bjails`                     | List active jails, one per line                                 |
| `f2bstatus [jail...]`          | One-line summary per jail: failed, banned now, banned in total  |
| `f2bbanned [jail...]`          | List banned addresses as `jail ip`                              |
| `f2bban <jail> <ip>`           | Ban an address in a jail                                        |
| `f2bunban <ip> [jail]`         | Unban an address, in every jail or only the one given           |
| `f2blog [N]`                   | Follow the log, starting with the last `N` lines (default 50)   |

`f2bstatus` and `f2bbanned` cover all jails when none are given.

```zsh
$ f2bstatus
JAIL             FAILED  BANNED  TOTAL
nginx-http-auth  0       0       0
sshd             2       2       5

$ f2bbanned
sshd 203.0.113.7
sshd 198.51.100.2

$ f2bunban 203.0.113.7
```

`f2blog` reads `/var/log/fail2ban.log`, or the journal (`journalctl -u
fail2ban`) when that file does not exist.
