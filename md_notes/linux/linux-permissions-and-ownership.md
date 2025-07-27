# Linux permissions

Permissions are established via the *chmod* command. Can be setted via octal or
string modes. Common examples:

```bash
chmod [option..] [mode..] target_file..
```

Permission values in octal and string format:

| Permission | Octal | String |
| ---------- | ----- | ------ |
| Read       | 4     | r      |
| Write      | 2     | w      |
| Execute    | 1     | x      |
| None       | 0     |        |

Most used octal modes for setting permissions:

| Permission String | Octal Mode |
| ----------------- | ---------- |
| rwx               | 7          |
| rw-               | 6          |
| r-x               | 5          |
| r--               | 4          |
| ---               | 0          |

NOTE: When using octal mode, the mode needs to be specified for all possible
members, i.e, the user, group, and others.

Giving all permissions to the owner and only read to group and others:

```bash
chmod 744 file

chmod u=rwx,go=r file
```

Common use case: adding execute permission to owner can simply be done as
follows:

```bash
chmod u+x file
```

## Initiating a root shell session

This is often useful but it needs to be done with care.

```bash
sudo -s
```
