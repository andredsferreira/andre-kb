variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "remote_network_cidr" {
  description = "CIDR block for the remote/on-prem network (used for hybrid nodes or VPN peering)"
  type        = string
  default     = "10.43.0.0/16"
}

variable "remote_pod_cidr" {
  description = "CIDR block for remote pod networking (used with EKS Hybrid Nodes)"
  type        = string
  default     = "10.44.0.0/16"
}

variable "ami_release_version" {
  description = "AMI release version to use for the EKS managed node group"
  type        = string
  default     = ""
}