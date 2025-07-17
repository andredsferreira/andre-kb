## The ls command

Lists the contents of a directory. Common options used in the ls command.

| Option | Description                                         |
| ------ | --------------------------------------------------- |
| -l     | Long format.                                        |
| -a     | Display all contents.                               |
| -A     | Display all contents except . and ..                |
| -S     | Sorts by file size.                                 |
| -t     | Sorts by last modified.                             |
| -h     | Human readable format (works well with -l option) . |
| -r     | Reverse the listing.                                |

Examples of usage.

```bash
# List by file size reversed and human readable.

ls -lAShr

# List by last modified reversed and human readable.

ls -lAthr
```
