# Process Control

## Important process signals

The names of the signals are derived from the C language standard.

| #   | Name  | Description          | Default Action | Can catch? | Can block? | Dump core? |
| --- | ----- | -------------------- | -------------- | ---------- | ---------- | ---------- |
| 1   | HUP   | Hangup               | Terminate      | Yes        | Yes        | No         |
| 2   | INT   | Interrupt            | Terminate      | Yes        | Yes        | No         |
| 3   | QUIT  | Quit                 | Terminate      | Yes        | Yes        | Yes        |
| 9   | KILL  | Kill                 | Terminate      | No         | No         | No         |
| 10  | BUS   | Bus error            | Terminate      | Yes        | Yes        | Yes        |
| 11  | SEGV  | Segmentation fault   | Terminate      | Yes        | Yes        | Yes        |
| 15  | TERM  | Software termination | Terminate      | Yes        | Yes        | No         |
| 17  | STOP  | Stop                 | Stop           | No         | Yes        | No         |
| 18  | TSTP  | Keyboard stop        | Stop           | Yes        | No         | No         |
| 19  | CONT  | Continue after stop  | Ignore         | Yes        | Yes        | No         |
| 28  | WINCH | Window changed       | Ignore         | Yes        | No         | No         |
| 30  | USR1  | User-defined #1      | Terminate      | Yes        | Yes        | No         |
| 31  | USR2  | User-defined #2      | Terminate      | Yes        | Yes        | No         |

## Killing processes

```bash
# List all avaialble signals

kill -l

# Kill a process specifying the signal
# kill [-signal] [pid]

kill -SIGINT 9887
kill -9 452 # Sends KILL signal 

# Kill by specfiyng process name or other attribute

# pkill [-signal] process_name
# pkill -u user user_processes
# pkill [process_name]
# pkill -u [process_user]

pkill httpd

# Sends SIGTERM to all processes owned by andre
pkill -u andre 

# Kills firefox processes owned by andre
pkill -u andre firefox 
```
## Process monitoring with ps

```bash
# Common flags used in the ps:
# a: show processes for all users
# u: display user oriented format
# x: include processes not attached to the terminal (eg. daemons, GUI apps)

ps aux

# Frequent pattern to identify a PID

ps aux | grep sshd
pgrep sshd
```

## Niceness value

Represent how "nice" a process is to others in the system. If a process as a
high niceness value it means it has low priority. If it has low niceness it
means it has high priority.

Values range: [-20, 19]

```bash
# Starting a process with a specified niceness level

# Example setting a nice value to 7
nice -n 7 path/to/process/executable

# Renicing a process
renice -15 pid
# Renicing all specific user processes
renice 10 -u andre
```
## The /proc pseudo-filesystem

The /proc is a pseudo-filesystem created by the kernel and is populated once
viewed directly (ls may display wrong data). It contains detailed informations
about processes when ps or top might not be enough.
