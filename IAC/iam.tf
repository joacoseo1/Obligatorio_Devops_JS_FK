# Role for ECS task execution
resource "aws_iam_role" "ecs_task_execution" {
  count              = var.existing_task_execution_role_name == null ? 1 : 0
  name               = "${var.project_name}-${var.env}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  count      = var.existing_task_execution_role_name == null ? 1 : 0
  role       = aws_iam_role.ecs_task_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role (if your app needs AWS resources)
resource "aws_iam_role" "ecs_task_role" {
  count              = var.existing_task_role_name == null ? 1 : 0
  name               = "${var.project_name}-${var.env}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Existing roles data sources (optional)
data "aws_iam_role" "existing_task_execution" {
  count = var.existing_task_execution_role_name != null ? 1 : 0
  name  = var.existing_task_execution_role_name
}

data "aws_iam_role" "existing_task_role" {
  count = var.existing_task_role_name != null ? 1 : 0
  name  = var.existing_task_role_name
}

# IAM role for ECS container instances (EC2)
data "aws_iam_policy_document" "ecs_instance_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  count              = var.existing_instance_profile_name == null ? 1 : 0
  name               = "${var.project_name}-${var.env}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_service" {
  count      = var.existing_instance_profile_name == null ? 1 : 0
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecr_read" {
  count      = var.existing_instance_profile_name == null ? 1 : 0
  role       = aws_iam_role.ecs_instance_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  count = var.existing_instance_profile_name == null ? 1 : 0
  name  = "${var.project_name}-${var.env}-ecs-instance-profile"
  role  = aws_iam_role.ecs_instance_role[0].name
}

data "aws_iam_instance_profile" "existing_instance_profile" {
  count = var.existing_instance_profile_name != null ? 1 : 0
  name  = var.existing_instance_profile_name
}

locals {
  task_execution_role_arn = var.existing_task_execution_role_name != null ? data.aws_iam_role.existing_task_execution[0].arn : aws_iam_role.ecs_task_execution[0].arn
  task_role_arn           = var.existing_task_role_name != null ? data.aws_iam_role.existing_task_role[0].arn : aws_iam_role.ecs_task_role[0].arn
  instance_profile_name   = var.existing_instance_profile_name != null ? data.aws_iam_instance_profile.existing_instance_profile[0].name : aws_iam_instance_profile.ecs_instance_profile[0].name
}

