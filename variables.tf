variable "control_plane_region" {
  type = string
  validation {
    condition     = contains(["staging", "northamerica-central-1"], var.control_plane_region)
    error_message = "The control plane region is not supported"
  }
}

variable "cluster_id" {
  description = "The Cluster ID"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

locals {
  tags = {
    ManagedBy = "cfke"
  }
}