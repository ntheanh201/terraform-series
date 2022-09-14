provider "aws" {
  region = "eu-central-1"
}

################################################################################
# EC2
################################################################################
#module "ec2" {
#  source = "./ec2"
#
#  instance_type = var.instance_type
#}

################################################################################
# S3
################################################################################

#module "s3" {
#  source = "./s3"
#
#  s3_bucket_name = var.s3_bucket_name
#}

################################################################################
# VPC
################################################################################

#module "vpc" {
#  source = "./vpc"
#
#  vpc_cidr_block    = "10.0.0.0/16"
#  private_subnet    = ["10.0.1.0/24", "10.0.2.0/24"]
#  public_subnet     = ["10.0.3.0/24", "10.0.4.0/24"]
#  availability_zone = ["eu-central-1a", "eu-central-1b"]
#}

################################################################################
# MODULES (MULTI-TIER APPLICATION)
################################################################################

locals {
  project = "terraform-series"
}

module "networking" {
  source = "./modules/networking"
}

module "database" {
  source = "./modules/database"
}

module "autoscaling" {
  source = "./modules/autoscaling"
}