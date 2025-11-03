# The Shell Environment

When the shell starts it sets up an environment which consists of *shell
variables*, *environment variables*, *aliases*, and *shell functions*. To do
that it reads from a variety of *startup files* (meaning these files contain the
definition of those variables, aliases, and functions).

The enviornment set up depends on the type of *shell session* started.

| Type of Session | Session Description                                                                                                                                   | Configuration Files                                      |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| Login Shell     | Started when the user logged in into a shell.                                                                                                         | /etc/profile, ~/.bash_profile, ~/.bash_login, ~./profile |
| Non-login Shell | Started when launched without login, typically through a GUI terminal emulator. Inherits the enviornemnt from parent process (usually a login shell). | /etc/bash.bashrc, ~/.bashrc                              |

For example, for a Debian system running lightdm: 

1. A user logins through lightdm.
2. Lightdm starts a login shell (/etc/profile and ~/.profile are sourced).
3. Lightdm launches the an X graphical session from that shell (also loading it's config files).
4. You start a terminal emulator, for which the parent process is the Xsession, meaning enviornemnt is inherited.
5. The terminal emulator starts a non-login shell (/etc/bash.bashrc and ~/.bashrc are sourced).

Login shell config files (read in the order presented):

| File             | Contents                                                                                                              |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| /etc/profile     | Global configuration script that applies to all users.                                                                |
| ~/.bash_profile  | Personal configuration script. Can extend or override global configurations.                                          |
| ~/.bash_login    | If ~/.bash_profile is not found this file is attempted instead.                                                       |
| ~/.profile       | Read if both ~/.bash_profile and ~/.bash_login are not found (default in Debian based distros).                       |

Non-login shell config files (read in the order presented):

| File             | Contents                                                                                                              |
| ---------------- | --------------------------------------------------------------------------------------------------------------------- |
| /etc/bash.bashrc | Global configuration script that applies to all users (basically a system wide .bashrc).                              |
| ~/.bashrc        | Personal configuration script. Can extend or override global configurations. Probably the most important config file. |

