# ==============================================================================
# ACCOUNT A (000000000000) IAM CONFIGURATION
# ==============================================================================

# ------------------------------------------------------------------------------
# Group 1: Programmatic / CLI-only Access (Members: engine, ci)
# ------------------------------------------------------------------------------
resource "aws_iam_group" "group1" {
  provider = aws.account_a
  name     = "group1-programmatic-only"
}

resource "aws_iam_user" "engine" {
  provider      = aws.account_a
  name          = "engine"
  force_destroy = true
  tags = {
    Type        = "ServiceAccount"
    AccessType  = "ProgrammaticOnly"
    Environment = "Production"
  }
}

resource "aws_iam_user" "ci" {
  provider      = aws.account_a
  name          = "ci"
  force_destroy = true
  tags = {
    Type        = "PipelineAccount"
    AccessType  = "ProgrammaticOnly"
    Environment = "Production"
  }
}

# Attach engine and ci to group1
resource "aws_iam_group_membership" "group1_membership" {
  provider = aws.account_a
  name     = "group1-membership"
  users = [
    aws_iam_user.engine.name,
    aws_iam_user.ci.name
  ]
  group = aws_iam_group.group1.name
}

# Explicitly deny AWS Management Console login / password management for group1
# (In addition to never provisioning aws_iam_user_login_profile)
resource "aws_iam_group_policy" "group1_cli_only_enforcement" {
  provider = aws.account_a
  name     = "DenyConsoleAccessPolicy"
  group    = aws_iam_group.group1.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyConsoleLoginProfileCreation"
        Effect = "Deny"
        Action = [
          "iam:CreateLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:ChangePassword"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# Group 2: Full Console + CLI Access (Members: alice, bob)
# ------------------------------------------------------------------------------
resource "aws_iam_group" "group2" {
  provider = aws.account_a
  name     = "group2-console-cli"
}

resource "aws_iam_user" "alice" {
  provider      = aws.account_a
  name          = "alice"
  force_destroy = true
  tags = {
    Type       = "HumanEngineer"
    AccessType = "ConsoleAndCLI"
    Department = "DevOps"
  }
}

resource "aws_iam_user" "bob" {
  provider      = aws.account_a
  name          = "bob"
  force_destroy = true
  tags = {
    Type       = "HumanEngineer"
    AccessType = "ConsoleAndCLI"
    Department = "DevOps"
  }
}

resource "aws_iam_group_membership" "group2_membership" {
  provider = aws.account_a
  name     = "group2-membership"
  users = [
    aws_iam_user.alice.name,
    aws_iam_user.bob.name
  ]
  group = aws_iam_group.group2.name
}

# ------------------------------------------------------------------------------
# roleA: Administrative Access to all AWS Services EXCEPT IAM
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "roleA_trust" {
  statement {
    sid     = "AllowAccountAIdentitiesToAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:root"]
    }
  }
}

resource "aws_iam_role" "roleA" {
  provider           = aws.account_a
  name               = "roleA"
  description        = "Administrative access to all AWS services except IAM"
  assume_role_policy = data.aws_iam_policy_document.roleA_trust.json
}

resource "aws_iam_role_policy" "roleA_admin_no_iam" {
  provider = aws.account_a
  name     = "AdminExceptIAMPolicy"
  role     = aws_iam_role.roleA.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAllServices"
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      },
      {
        Sid    = "DenyIAMAdministration"
        Effect = "Deny"
        Action = [
          "iam:*",
          "organizations:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# roleB: Role whose ONLY permission is to assume roleC in Account B
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "roleB_trust" {
  statement {
    sid     = "AllowAccountAPrincipalsToAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_a_id}:root"]
    }
  }
}

resource "aws_iam_role" "roleB" {
  provider           = aws.account_a
  name               = "roleB"
  description        = "Role whose sole permission is to assume roleC in Account B"
  assume_role_policy = data.aws_iam_policy_document.roleB_trust.json
}

resource "aws_iam_role_policy" "roleB_assume_roleC" {
  provider = aws.account_a
  name     = "AssumeRoleCInAccountBOnly"
  role     = aws_iam_role.roleB.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowAssumeRoleCInAccountB"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::${var.account_b_id}:role/roleC"
      }
    ]
  })
}
