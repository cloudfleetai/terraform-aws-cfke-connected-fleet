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

variable "create_spot_service_linked_role" {
  type        = bool
  default = true
  description = "Create the AWS Service Linked Role for Spot Instances. Set this to false if you are using an account that already has the role. See https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/service-linked-roles-spot-instance-requests.html for more information."
}

locals {
  tags = {
    ManagedBy = "cfke"
  }
}