terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.44.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
}

# Create IAM user for admin
resource "aws_iam_user" "admin_user" {
  name = "admin-user"
}

# Attach admin policy (consider least privilege in prod)
resource "aws_iam_user_policy_attachment" "admin_attach" {
  user       = aws_iam_user.admin_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Generate random password (secure, no hardcode)
resource "random_password" "admin_password" {
  length  = 20
  special = true
}

resource "aws_iam_user_login_profile" "admin_user_console" {
  user                    = aws_iam_user.admin_user.name
  password                = random_password.admin_password.result
  password_reset_required = true
}

output "admin_console_password" {
  value     = random_password.admin_password.result
  sensitive = true
}

# Example: Programmatic access (optional, store in GitHub secrets)
resource "aws_iam_access_key" "admin_access_key" {
  user = aws_iam_user.admin_user.name
}

output "admin_access_key_id" {
  value     = aws_iam_access_key.admin_access_key.id
  sensitive = true
}

output "admin_secret_access_key" {
  value     = aws_iam_access_key.admin_access_key.secret
  sensitive = true
}
