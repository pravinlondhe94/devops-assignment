# DevOps Assignment

This repository contains Terraform-based AWS assignments.

## Task 1: EC2 Infrastructure
- Provision multiple EC2 instances using Terraform.
- Configure instance parameters, tags, and outputs.

## Task 2: Remote State and Locking
- Configure an S3 backend for Terraform remote state.
- Configure DynamoDB state locking.

## Task 3: IAM and Cross-Account Access
- Configure IAM users, groups, and roles.
- Set up cross-account role assumption.

## Task 4: Least-Privilege CI Policy
- Configure permissions to push Docker images to Amazon ECR.
- Allow deployment updates to a specific ECS service.
- Provide read-only access to a specific S3 bucket.

## Security Notes
- Do not commit AWS credentials, secrets, Terraform state files, or sensitive `.tfvars` files.
- Replace example account IDs and resource names with actual values before applying Terraform.
