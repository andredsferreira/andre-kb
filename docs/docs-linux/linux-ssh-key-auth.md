# SSH Key-Based Authentication 

Small tutorial for setting up an SSH server (Alpine distro) with key based
authentication. It assumes open-ssh is installed.

## 1. Generate SSH key pair on client

```bash
ssh-keygen -t ed25519 -f ~/.ssh/my_custom_key
```

## 2. Copy the key to the server

```bash
ssh-copy-id -i ~/.ssh/my_custom_key.pub user@server

# With specific SSH port
ssh-copy-id -i ~/.ssh/my_custom_key.pub -o Port=12353 user@server

```

## 3. Disable password authentication on server

WARNING : Ensure you have indeed copied the client key to the server otherwise
you will be locked out!

```bash
sudo micro /etc/ssh/sshd_config
```

Edit the following lines:

```
PasswordAuthentication no
PubkeyAuthentication yes
ChallengeResponseAuthentication no
```

## 4. Restart the ssh-server service

```bash
sudo rc-service sshd restart
```

## 5. Create a user other than root

Example is for Alpine based distributions.

```bash
adduser myuser
addgroup myuser wheel
apk add sudo
micro /etc/sudoers
```

Uncomment the following line in /etc/sudoers:

```
# %wheel ALL=(ALL) ALL
```

## 5. Additional security measures

* Change the default listening port from 22 (clients must specify the new port
* when connecting).
* Disable root login (look for PermitRootLogin on /etc/ssh/sshd_config)
* Restrict ssh access via a firewall