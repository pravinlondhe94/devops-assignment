terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "account_a_id" {
  description = "Account ID of Account A"
  type        = string
  default     = "000000000000"
}

variable "target_s3_bucket_name" {
  description = "Name of the single S3 bucket roleC is permitted to access"
  type        = string
  default     = "account-b-production-artifacts-111111111111"
}

# ==============================================================================
# FIXED IMPLEMENTATION
# ==============================================================================

# FIX #1: Corrected principal identifier from "user/roleB" to "role/roleB"
data "aws_iam_policy_document" "roleC_trust" {
  statement {
    sid     = "AllowRoleBFromAccountAToAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      # FIXED: Changed from "arn:aws:iam::000000000000:user/roleB"
      # roleB is an IAM Role, therefore its ARN prefix is role/
      identifiers = ["arn:aws:iam://${var.account_a_id}:role/roleB"]
    }
  }
}

resource "aws_iam_role" "roleC" {
  name               = "roleC"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json

  tags = {
    Role        = "roleC"
    AssumedBy   = "arn:aws:iam://${var.account_a_id}:role/roleB"
    Environment = "Production"
  }
}

# FIX #2: Scoped permissions from wild-card "*" to the specific named S3 bucket
# and its objects, satisfying Task 3's strict requirement for single-bucket access.
resource "aws_iam_role_policy" "roleC_s3" {
  name = "roleC-s3-access"
  role = aws_iam_role.roleC.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FullAccessToSpecificBucketAndObjects"
        Effect = "Allow"
        Action = "s3:*"
        # FIXED: Changed from Resource = "*" to explicit bucket ARN and object ARN
        Resource = [
          "arn:aws:s3:::${var.target_s3_bucket_name}",
          "arn:aws:s3:::${var.target_s3_bucket_name}/*"
        ]
      }
    ]
  })
}
