# Scalable way to fetch AMIs

# Ubuntu 22.04 LTS x86_64

data "aws_ami" "ubuntu_22_x86" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Ubuntu 22.04 LTS ARM64

data "aws_ami" "ubuntu_22_arm" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

# Debian 12 x86_64

data "aws_ami" "debian_12_x86" {
  most_recent = true
  owners      = ["136693071363"] # Debian official

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
}

# Debian 12 ARM64

data "aws_ami" "debian_12_arm" {
  most_recent = true
  owners      = ["136693071363"]

  filter {
    name   = "name"
    values = ["debian-12-arm64-*"]
  }
}

# RHEL 10 x86_64

data "aws_ami" "rhel_10_x86" {
  most_recent = true
  owners      = ["309956199498"] # RedHat

  filter {
    name   = "name"
    values = ["RHEL-10.*_HVM-*-x86_64-*"]
  }
}

# RHEL 10 ARM64

data "aws_ami" "rhel_10_arm" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-10.*_HVM-*-aarch64-*"]
  }
}

# Windows 2022

data "aws_ami" "windows_2022" {
  most_recent = true
  owners      = ["801119661308"] # Microsoft

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}
