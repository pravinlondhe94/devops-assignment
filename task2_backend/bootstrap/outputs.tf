output "s3_bucket_name" {
  description = "Name of the S3 bucket created for Terraform remote state"
  value       = aws_s3_bucket.tf_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket created for Terraform remote state"
  value       = aws_s3_bucket.tf_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table created for Terraform state locking"
  value       = aws_dynamodb_table.tf_locks.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table created for Terraform state locking"
  value       = aws_dynamodb_table.tf_locks.arn
}

output "backend_config_snippet" {
  description = "Backend configuration block to copy into consumer modules"
  value       = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.tf_state.id}"
        key            = "path/to/terraform.tfstate"
        region         = "${aws_s3_bucket.tf_state.region}"
        dynamodb_table = "${aws_dynamodb_table.tf_locks.id}"
        encrypt        = true
      }
    }
  EOT
}
