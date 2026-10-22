variable "aws_region" {
  description = "Default AWS region"
  type        = string
  default     = "us-east-1"
}

variable "account_a_id" {
  description = "AWS Account ID for Account A"
  type        = string
  default     = "000000000000"
}

variable "account_b_id" {
  description = "AWS Account ID for Account B"
  type        = string
  default     = "111111111111"
}

variable "account_b_bucket_name" {
  description = "Name of the target S3 bucket in Account B"
  type        = string
  default     = "account-b-production-artifacts-111111111111"
}
