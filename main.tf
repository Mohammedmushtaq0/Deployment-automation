#################################
# Provider & Variables
#################################
provider "aws" {
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
  region     = var.AWS_REGION
}

#################################
# IAM - Admin User
#################################
resource "aws_iam_user" "admin_user" {
  name = "admin-user"
}

resource "aws_iam_user_login_profile" "admin_user_console" {
  user                      = aws_iam_user.admin_user.name
  password                  = "YourCustomPassword123!"
  password_reset_required   = false
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
        Effect   = "Allow"
        Action   = [
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

#################################
# IAM - ECR & ECS User
#################################
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
        Effect   = "Allow"
        Action   = [
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

#################################
# ECR Repository
#################################
resource "aws_ecr_repository" "app_repo" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#################################
# CloudWatch Logs for ECS
#################################
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
}

#################################
# ECS Cluster
#################################
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-cluster"
}

#################################
# ECS Task Execution Role
#################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#################################
# ECS Task Definition
#################################
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = var.image_uri
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.AWS_REGION
          awslogs-stream-prefix = var.app_name
        }
      }
    }
  ])
}

#################################
# Networking (Default VPC)
#################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#################################
# ECS Service
#################################
resource "aws_security_group" "ecs_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow HTTP access to container"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

#################################
# Outputs
#################################
output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}

