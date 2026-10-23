#!/usr/bin/env bash
set -euo pipefail

user_management() {

  # Add an user to Linux.  
  useradd -m -s /bin/bash username

  # Delete an user and it's home directory (-r).
  userdel -r username

  # Set/change the password of an user.
  passwd username

  # Force a password change on next login.
  passwd -e username

  # Add an user to a group.
  usermod -aG groupname username

  # List an user's groups
  groups username
}

rsync() {

  rsync -avhz -e "ssh -p 10022 -i /path/identity/file" /local/path user@remote:/remote/path

}

dns() {

  dig @1.1.1.1 portugal.gov.pt TXT +noall +answer

  dig @1.1.1.1 portugal.gov.pt

  dig -x 1.1.1.1

}

