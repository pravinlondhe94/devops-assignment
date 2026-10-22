# devops-terraform-assignment
Terraform, AWS IAM, EC2, remote state and least-privilege policy assignments
# DevOps Terraform Assignment

## Overview

This repository contains my hands-on AWS and Terraform assignment work.

## Tasks

### Task 1 — EC2 Infrastructure
Terraform configuration for provisioning EC2 instances using reusable variables, outputs, and lifecycle protection.

### Task 2 — Remote State and Locking
S3 remote state backend configuration, S3 versioning and encryption, and DynamoDB-based state locking.

### Task 3 — Multi-Account IAM and Cross-Account Access
IAM groups, users, role permissions, and cross-account role assumption configuration examples.

### Task 4 — Least-Privilege IAM Policy
A custom IAM policy for ECR image publishing, ECS deployment, and read-only S3 build artifact access.

## Security

- Sensitive values, AWS credentials, and Terraform state files are excluded from version control.
- Example configuration values should be replaced with appropriate values in the deployment environment.
- AWS resources and permissions should be validated before deployment.

## Tools

- Terraform
- AWS IAM
- Amazon EC2
- Amazon S3
- Amazon DynamoDB
- Amazon ECR
- Amazon ECS
- Git and GitHub
