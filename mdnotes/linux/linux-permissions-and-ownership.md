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

## Ownership

To change ownership the chown command is used:

```bash
chown [owner]:[group] file...
```

Changing ownership of the file to user andre:

```bash
chown andre file
```

Changing ownership of the file to user andre, and it's login group:

```bash
chown andre: file
```

Specifying both new owner and group:

```bash
chown andre:users file
```

Only changing the group:

```bash
chown :users file
```

Setting the groupid in a specific directory, this makes it that every file or
directory created inside it will inherit it's group, not the creator's group.

```bash
chmod g+s /path/to/dir
```