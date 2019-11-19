variable "REGION" {}
variable "PROFILE" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

provider "aws" {
  region  = var.REGION
  profile = var.PROFILE
}

