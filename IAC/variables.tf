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
  default = "stockwiz"
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
  default = 3000
}

