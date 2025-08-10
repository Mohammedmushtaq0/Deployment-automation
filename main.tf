# ECS Cluster
resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.app_name}-cluster"
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app_task" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.ecs_task_execution_role_arn

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

# ECS Service
resource "aws_ecs_service" "app_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [aws_security_group.app_sg.id]
    assign_public_ip = true
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc_id

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

# --- App Autoscaling ---
resource "aws_appautoscaling_target" "ecs_service" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.app_cluster.name}/${aws_ecs_service.app_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based scaling policy (scale out)
resource "aws_appautoscaling_policy" "cpu_scale_out" {
  name               = "${var.app_name}-cpu-scale-out"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown = 60
    scale_in_cooldown  = 60
  }
}

# CPU-based scaling policy (scale in)
resource "aws_appautoscaling_policy" "cpu_scale_in" {
  name               = "${var.app_name}-cpu-scale-in"
  service_namespace  = "ecs"
  resource_id        = aws_appautoscaling_target.ecs_service.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = 30.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_out_cooldown = 60
    scale_in_cooldown  = 60
  }
}

# Outputs
output "ecs_cluster_name" {
  value = aws_ecs_cluster.app_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}
