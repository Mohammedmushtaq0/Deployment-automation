variable "app_name" {
  description = "Name of the ECS application"
  type        = string
}

variable "image_uri" {
  description = "Full URI of the Docker image in ECR"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 80
}

variable "subnets" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the ALB Target Group to associate with ECS service"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
