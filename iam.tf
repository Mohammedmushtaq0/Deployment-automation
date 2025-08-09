provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = var.AWS_REGION
}

resource "aws_iam_user" "admin_user" {
  name = "admin-user"
}

resource "aws_iam_user_login_profile" "admin_user_console" {
  user    = aws_iam_user.admin_user.name
  password = "YourCustomPassword123!"
  password_reset_required = false
}

output "admin_user_console_login" {
  description = "AWS Console login details for admin-user"
  value = {
    login_name = aws_iam_user.admin_user.name
    password   = aws_iam_user_login_profile.admin_user_console.password
    login_link = "https://console.aws.amazon.com/"
    note       = "Use your AWS account ID or alias with the login name."
  }
}

resource "aws_iam_policy" "admin_user_policy" {
  name        = "AdminUserPolicy"
  description = "Allows creating users, attaching policies, and managing ECR/ECS."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:List*",
          "iam:Get*",
          "ecr:*",
          "ecs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "admin_user_policy_attach" {
  user       = aws_iam_user.admin_user.name
  policy_arn = aws_iam_policy.admin_user_policy.arn
}

resource "aws_iam_user" "ECR_ECS_user" {
  name = "ECR_ECS_user"
}

resource "aws_iam_policy" "ECR_ECS_user_policy" {
  name        = "ECR_ECS_user_policy"
  description = "Full access to ECR and ECS for ECR_ECS_user."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*",
          "ecs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ECR_ECS_user_policy_attach" {
  user       = aws_iam_user.ECR_ECS_user.name
  policy_arn = aws_iam_policy.ECR_ECS_user_policy.arn
}

# resource "aws_ecr_repository" "images_repo" {
#   name = "images/repo"
# }

# resource "aws_cloudwatch_log_group" "ecr_events" {
#   name = "/aws/ecr/events"
#   retention_in_days = 14
# }

# resource "aws_cloudwatch_event_rule" "ecr_image_actions" {
#   name        = "ECRImageActionsRule"
#   description = "Capture ECR image push, pull, and delete events."
#   event_pattern = jsonencode({
#     source = ["aws.ecr"],
#     detail_type = ["ECR Image Action"],
#     detail = {
#       "action-type" = ["PUSH", "PULL", "DELETE"]
#     }
#   })
# }

# resource "aws_cloudwatch_event_target" "ecr_events_to_logs" {
#   rule      = aws_cloudwatch_event_rule.ecr_image_actions.name
#   arn       = aws_cloudwatch_log_group.ecr_events.arn
# }
