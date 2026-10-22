terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider pointing to Account A
provider "aws" {
  alias  = "account_a"
  region = var.aws_region
  # In actual multi-account setups, assume role or use named profile:
  # assume_role {
  #   role_arn = "arn:aws:iam::000000000000:role/OrganizationAccountAccessRole"
  # }
}

# Secondary provider pointing to Account B
provider "aws" {
  alias  = "account_b"
  region = var.aws_region
  # In actual multi-account setups, assume role or use named profile:
  # assume_role {
  #   role_arn = "arn:aws:iam::111111111111:role/OrganizationAccountAccessRole"
  # }
}
