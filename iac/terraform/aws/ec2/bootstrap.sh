#!/bin/bash

set -e

echo "Updating package lists..."
sudo apt-get update -y

echo "Upgrading installed packages..."
sudo apt-get upgrade -y

echo "Performing full distribution upgrade..."
sudo apt-get dist-upgrade -y

echo "Removing unnecessary packages..."
sudo apt-get autoremove -y
sudo apt-get autoclean -y

echo "System update complete."
