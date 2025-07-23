#!/bin/bash

current_user="$USER"
backup_dir="$(pwd)/simple_backup"

mkdir -p "$backup_dir"

# Define backup filename with date
backup_file="${backup_dir}/home_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

# Path to user's home directory
home_dir="/home/${current_user}"

# Check if home directory exists
if [[ ! -d "$home_dir" ]]; then
  echo "Error: Home directory $home_dir does not exist."
  exit 1
fi

# Perform backup named $backup_file to $home_dir
tar -czf "$backup_file" "$home_dir"

# Check if tar command succeeded

# $? is a special variable that holds the exit status of the last
# executed command

# -eq means equal compairson so the if statement basically checks
# if the exit status of the last comman was 0 (successful)

if [[ $? -eq 0 ]]; then
  echo "Backup successful! File saved to $backup_file"
else
  echo "Backup failed!"
  exit 1
fi
