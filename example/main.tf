provider "aws" {
  region = "us-east-1"
}

module "cfke-cluster" {
  source               = "../"
  cluster_id           = "ea4ba2ac-3262-4c51-9a08-e13c98e50aab"
  control_plane_region = "northamerica-central-1"
}