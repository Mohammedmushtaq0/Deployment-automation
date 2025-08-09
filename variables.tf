variable "AWS_ACCESS_KEY_ID" {
  description = "AWS access key ID"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "AWS_REGION" {
  description = "AWS region"
  type        = string
}

variable "app_name" {
  description = "Application name used for ECR/ECS resources"
  type        = string
  default     = "my-app"
}

variable "container_port" {
  description = "Port your container listens on"
  type        = number
  default     = 3000
}
variable "image_uri" {
  description = "Full image URI for ECS task"
  type        = string
}

