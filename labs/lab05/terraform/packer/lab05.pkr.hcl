packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.3.0"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "compose_version" {
  type    = string
  default = "v2.29.7"
}

locals {
  timestamp = formatdate("YYYYMMDD-hhmm", timestamp())
}

source "amazon-ebs" "lab05" {
  region        = var.region
  instance_type = "t4g.micro"
  ssh_username  = "ec2-user"
  ami_name      = "lab05-docker-arm64-${local.timestamp}"

  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-kernel-*-arm64"
      architecture        = "arm64"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "lab05-docker-arm64"
    Base = "al2023"
  }
}

build {
  name    = "lab05"
  sources = ["source.amazon-ebs.lab05"]

  provisioner "shell" {
    environment_vars = ["COMPOSE_VERSION=${var.compose_version}"]
    inline = [
      "set -euxo pipefail",

      # Patch and install Docker
      "sudo dnf update -y",
      "sudo dnf install -y docker",
      "sudo systemctl enable docker",

      # Compose v2 plugin (arm64 build)
      "sudo mkdir -p /usr/local/lib/docker/cli-plugins",
      "sudo curl -fsSL https://github.com/docker/compose/releases/download/$${COMPOSE_VERSION}/docker-compose-linux-aarch64 -o /usr/local/lib/docker/cli-plugins/docker-compose",
      "sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose",

      # Let ec2-user run docker without sudo
      "sudo usermod -aG docker ec2-user",

      # Smoke test (daemon isn't running during build, so only check the client)
      "docker --version",
      "/usr/local/lib/docker/cli-plugins/docker-compose version",

      # Shrink the image
      "sudo dnf clean all",
    ]
  }
}