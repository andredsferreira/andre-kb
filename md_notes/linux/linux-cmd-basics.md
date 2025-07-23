# Linux Command Line Basics

Some notes taken from the book The Linux Command Line by William Shotts.

## The ls command

Lists the contents of a directory. Common options used in the ls command.

| Option | Description                                                                                   |
| ------ | --------------------------------------------------------------------------------------------- |
| -l     | Long format.                                                                                  |
| -a     | Display all contents.                                                                         |
| -A     | Display all contents except . and ..                                                          |
| -S     | Sorts by file size.                                                                           |
| -t     | Sorts by last modified.                                                                       |
| -h     | Human readable format (works well with -l option) .                                           |
| -r     | Reverse the listing.                                                                          |
| -i     | Reveals inode numbers (useful for seeing if hard links exist: the have the same inode number) |

Listing by file size reversed and human readable:

```bash
ls -lAShr
```

List by last modified reversed and human readable:

```bash
ls -lAthr
```

## The cp command

Here are some uncommon but useful uses.

NOTE: The -a option preserves permissions, timestamps, symlinks, etc.

NOTE: The -v means verbose and shows details of copy.

Copying in interactive mode, meaning the user is prompted if something is to be
overwritten:

```bash
cp -i file1 file2
```

Copying a directory to another:

```bash
cp -r dir1 dir2
```

Copying all non-hidden files (preserving properties) in a directory to another:

```bash
cp -a dir1/* dir2
```

## The mv command

Used to move files and also *renaming* them. The mv command overwrittes files
and dirs by default.

```bash
mv file1 file2
```

Only moving files that don't exist in the destination (updating):

```bash
mv -u file dir/
```

## The ln command

Before diving into the ln command here is the definition for hard and symbolic
links.

*Hard link*: A special file that represents a text pointer to another file only.
Cannot point to files outside the link's filesystem, and cannot reference
directories. Hard links aPre not visible when using the ls command. 

*Symbolic link*: A special file that represents a text pointer to another file
or directory. If the link is deleted the original file or directory lives.
Symbolic links are more modern and prefered to hard links (similar to Windows
shortcuts).

In general we have:

```bash
ln [TARGET] [LINK_NAME]
```

Creating a hard link:

```bash
ln file link
```

Creating a symbolic link (item is either a file or directory):

```bash
ln -s item link
```

NOTE: broken symbolic links can exists and occur when the original file they
point is deleted but the link still exists.