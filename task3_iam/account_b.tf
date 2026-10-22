# ==============================================================================
# ACCOUNT B (111111111111) IAM & S3 CONFIGURATION
# ==============================================================================

# ------------------------------------------------------------------------------
# Target S3 Bucket in Account B
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "target_bucket" {
  provider      = aws.account_b
  bucket        = var.account_b_bucket_name
  force_destroy = false

  tags = {
    Name        = var.account_b_bucket_name
    Environment = "Production"
    Account     = "AccountB"
  }
}

resource "aws_s3_bucket_versioning" "target_bucket_versioning" {
  provider = aws.account_b
  bucket   = aws_s3_bucket.target_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "target_bucket_encryption" {
  provider = aws.account_b
  bucket   = aws_s3_bucket.target_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "target_bucket_pab" {
  provider = aws.account_b
  bucket   = aws_s3_bucket.target_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# roleC: Full access to single named S3 bucket, assumable ONLY by roleB (Account A)
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "roleC_trust" {
  statement {
    sid     = "TrustOnlyRoleBFromAccountA"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      # Crucial: Must be role/roleB, NOT root and NOT user/roleB.
      # This strictly enforces that ONLY roleB can assume roleC, nothing else.
      identifiers = ["arn:aws:iam::${var.account_a_id}:role/roleB"]
    }
  }
}

resource "aws_iam_role" "roleC" {
  provider           = aws.account_b
  name               = "roleC"
  description        = "Role allowing full access to target S3 bucket, restricted to roleB in Account A"
  assume_role_policy = data.aws_iam_policy_document.roleC_trust.json
}

resource "aws_iam_role_policy" "roleC_single_bucket_access" {
  provider = aws.account_b
  name     = "roleC-single-bucket-access"
  role     = aws_iam_role.roleC.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "FullAccessToNamedBucketAndObjects"
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.target_bucket.arn,
          "${aws_s3_bucket.target_bucket.arn}/*"
        ]
      }
    ]
  })
}
