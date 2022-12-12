terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket  = "krp-project-tfstate"
    key     = "evtours.tfstate"
    region  = "us-east-2"
    encrypt = "true"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.46.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      environment = "dev"
      project     = "https://github.com/keithly/evtours"
    }
  }
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_id          = data.aws_caller_identity.current.account_id
  ecr_repository_name = var.function_name
}
