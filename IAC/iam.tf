###############################################
# IAM: Solo referenciar roles/perfiles existentes
# Eliminamos creación de roles porque el usuario no
# tiene permisos (AccessDenied) y no desea manejar IAM.
#
# Requerir en terraform.tfvars:
# existing_task_execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
# existing_task_role_arn           = "arn:aws:iam::123456789012:role/ecsAppTaskRole" (opcional)
# existing_instance_profile_name   = "ecsInstanceProfile" (perfil ya creado con rol EC2ContainerServiceforEC2Role)
###############################################

variable "existing_task_execution_role_arn" {
  type        = string
  description = "ARN de un rol IAM existente para task execution (obligatorio)"
}

variable "existing_task_role_arn" {
  type        = string
  default     = null
  description = "ARN de un rol IAM existente para task role (opcional)"
}

variable "existing_instance_profile_name" {
  type        = string
  description = "Nombre de instance profile existente para instancias ECS EC2"
}

data "aws_iam_instance_profile" "existing_instance_profile" {
  name = var.existing_instance_profile_name
}

locals {
  task_execution_role_arn = var.existing_task_execution_role_arn
  task_role_arn           = var.existing_task_role_arn != null ? var.existing_task_role_arn : var.existing_task_execution_role_arn
  instance_profile_name   = data.aws_iam_instance_profile.existing_instance_profile.name
}

