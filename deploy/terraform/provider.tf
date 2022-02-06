terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }
  required_version = ">= 1.1.5"
}

variable "aws_region" {
  default = ""
}

provider "aws" {
  region = var.aws_region
}
