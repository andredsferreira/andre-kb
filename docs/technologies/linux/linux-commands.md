| Command                          | Description                                                        |
| -------------------------------- | ------------------------------------------------------------------ |
| useradd -m -s /bin/bash username | Add an user to Linux.                                              |
| userdel -r username              | Remove an user along with its home directory (-r flag).            |
| passwd username                  | Set/change an user's password.                                     |
| passwd -e username               | Force change password on next login (still requires old password). |
| usermod -aG groupname username   | Adds an user to a group.                                           |

|                                      |                                                        |
| ps a                                 | Processes attached to the current terminal.            |
| ps x                                 | Your user processes.                                   |
| ps ax                                | All processes on the system.                           |
| ps ax -o user, pid, comm --sort=user | Shows 3 columns and sorts by user.                     |
|                                      |                                                        |

## Fun Commands

| Command                        | Description                                                                                                               |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| dig @f.root-servers.net . AXFR | Asks the server for all the records it contains (some servers may not allow this the f root server, managed by ISC does). |

