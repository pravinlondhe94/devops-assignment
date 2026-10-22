terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "ci_user_name" {
  description = "Name of the CI IAM User"
  type        = string
  default     = "ci"
}

variable "ecr_repository_arn" {
  description = "Target ECR repository ARN for image pushes"
  type        = string
  default     = "arn:aws:ecr:us-east-1:000000000000:repository/my-app-repo"
}

variable "ecs_cluster_name" {
  description = "Target ECS Cluster name"
  type        = string
  default     = "my-ecs-cluster"
}

variable "ecs_service_arn" {
  description = "Target ECS Service ARN for deployments"
  type        = string
  default     = "arn:aws:ecs:us-east-1:000000000000:service/my-ecs-cluster/my-app-service"
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role that CI can pass to ECS"
  type        = string
  default     = "arn:aws:iam::000000000000:role/my-app-ecs-execution-role"
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS Task Role that CI can pass to ECS"
  type        = string
  default     = "arn:aws:iam::000000000000:role/my-app-ecs-task-role"
}

variable "artifact_bucket_name" {
  description = "Name of the S3 bucket storing build artifacts"
  type        = string
  default     = "my-ci-build-artifacts-bucket"
}

# Standalone Managed Policy enforcing strict least-privilege for CI
resource "aws_iam_policy" "ci_least_privilege" {
  name        = "CI-Pipeline-Deployment-Policy"
  description = "Scoped policy granting push to ECR repo, deploy to ECS service, and read-only S3 artifact bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. ECR: Authorization token (must be Resource: *)
      {
        Sid      = "ECRAuthTokenGlobal"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      # 2. ECR: Layer & Image push scoped strictly to the target repository
      {
        Sid    = "ECRPushImageToSpecificRepo"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = var.ecr_repository_arn
      },
      # 3. ECS: Register & describe task definitions (Resource * required by AWS IAM for RegisterTaskDefinition)
      {
        Sid    = "ECSDescribeAndRegisterTaskDefinition"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = "*"
      },
      # 4. ECS: Update only the target ECS service
      {
        Sid    = "ECSUpdateSpecificService"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = var.ecs_service_arn
      },
      # 5. IAM: PassRole strictly scoped to ECS tasks and the specific execution/task roles
      {
        Sid    = "PassRoleToECSTasksOnly"
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          var.ecs_execution_role_arn,
          var.ecs_task_role_arn
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      },
      # 6. S3: Read-only access to specific build artifacts bucket (Bucket Level)
      {
        Sid    = "S3ListBuildArtifactsBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::${var.artifact_bucket_name}"
      },
      # 7. S3: Read-only access to objects inside the bucket (Object Level)
      {
        Sid    = "S3ReadBuildArtifactsObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.artifact_bucket_name}/*"
      }
    ]
  })
}

# Attach policy to ci user
resource "aws_iam_user_policy_attachment" "ci_policy_attachment" {
  user       = var.ci_user_name
  policy_arn = aws_iam_policy.ci_least_privilege.arn
}
