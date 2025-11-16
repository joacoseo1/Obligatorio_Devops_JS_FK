variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_account_id" {
  type        = string
  description = "Tu AWS Account ID (12 digits)"
}

variable "project_name" {
  type    = string
  default = "obligatoriodevops"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "desired_count" {
  type    = number
  default = 1
}

# Ports
variable "app_container_port" {
  type    = number
  default = 8000
}

variable "image_tag_api" {
  type    = string
  default = "latest"
}

variable "image_tag_product" {
  type    = string
  default = "latest"
}

variable "image_tag_inventory" {
  type    = string
  default = "latest"
}

# ECS EC2 capacity (Auto Scaling Group)
variable "ecs_instance_type" {
  type    = string
  default = "t3.small"
}

variable "ecs_asg_min_size" {
  type    = number
  default = 1
}

variable "ecs_asg_max_size" {
  type    = number
  default = 3
}

variable "ecs_asg_desired_size" {
  type    = number
  default = 1
}

variable "ecs_ssh_key_name" {
  type        = string
  default     = null
  description = "Optional: EC2 key pair name for SSH (set to null to disable)"
}

variable "ecs_instance_disk_size" {
  type    = number
  default = 30
}

# Optional: use pre-existing IAM instead of creating
variable "existing_task_execution_role_name" {
  type        = string
  default     = null
  description = "If set, use this IAM role for ECS task execution instead of creating one"
}

variable "existing_task_role_name" {
  type        = string
  default     = null
  description = "If set, use this IAM role for ECS task taskRole instead of creating one"
}

variable "existing_instance_profile_name" {
  type        = string
  default     = null
  description = "If set, use this EC2 instance profile for ECS instances instead of creating one"
}