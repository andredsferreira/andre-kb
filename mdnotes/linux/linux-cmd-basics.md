# Linux Command Line Basics

Some notes taken from the book The Linux Command Line by William Shotts.

## The printenv command

Used to print the enviornment variables

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

## The mkdir command

Simple flag option: use -p and it will give no error if the directory already
exists.

```bash
mkdir -p dir_name
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

## Redirection

| File Descriptor | Name   |
| --------------- | ------ |
| 0               | stdin  |
| 1               | stdout |
| 2               | stderr |

The > operator redirects the output of the command. It always truncates the file
to which it points. If the file does not exist it creates it.

Trick to truncate or create e new file is simply put the > with no command
before it:

```bash
> filename.extension
```

The >> appends instead of truncating the destination file. If the file does not
exist it creates it.

```bash
ls -l >> ls-contents.txt
```

To redirect the errors from commands we need to specify the file descriptor:

```bash
ls -l /nonexistent/path 2> error.txt
```

Redirecting both standard output and standard error:

```bash
ls -l /some/path &> out.txt

ls -l /some/path &>> out.txt
```

Some commands make use of the standard input, the most known example is cat. We
can redirect the standard input to cat like so (not very usefull for cat):

```bash
cat < hello.txt
```

## Tailing files in realtime 

The tail (and head) has a useful option for tailing files in realtime:

```bash
tail -f /var/log/messages
```

## The tee command

The tee command copies the output to a specified file(s) but also to the
standard output. This is specially usefull to allow data to continue down a
pipeline

It's also usefull if we want to also see the output at the same time we saved it
in a file.

In the example bellow we save the output of ls in output.txt but also pipe it to
grep and sort.

```bash

ls /usr/bin/ | tee output.txt | grep zip | sort

ls /usr/bin/ | grep zip | sort | tee output.txt

```

## Brace expansion

Brace expansion is useful for creating several documents or directories. The
following will expand to file01.txt, file02.txt, etc.

```bash
echo file{01..10}.txt
```

Using xargs and touch to create multiple files:

```bash
echo file{01..10}.txt | xargs touch
```

Using mkdir and brace expansion to create multiple directories:

```bash
mkdir photos-{2007..2009}-{01..12}
```

## Command substitution

Can be performed with $(command). It allows the use of command outputs as
expansions. Entire pipelines can be used.

```bash
echo $(ls)
echo $(pgrep firefox)
ls -l $(which go)
file $(ls -d /usr/bin/* | grep zip)
```

## The history command

Simple trick to run a specific command in history line x:

```bash
!x
```

