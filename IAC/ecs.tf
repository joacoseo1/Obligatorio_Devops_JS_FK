resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-${var.env}-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.env}"
  retention_in_days = 14
}

# Launch template for ECS EC2 instances
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.project_name}-${var.env}-ecs-lt-"
  image_id      = data.aws_ssm_parameter.ecs_optimized_ami.value
  instance_type = var.ecs_instance_type
  key_name      = var.ecs_ssh_key_name

  vpc_security_group_ids = [aws_security_group.ecs_instances_sg.id]

  iam_instance_profile {
    name = local.instance_profile_name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.ecs_instance_disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
              systemctl enable --now ecs
              EOF
  )
}

resource "aws_autoscaling_group" "ecs" {
  name                      = "${var.project_name}-${var.env}-ecs-asg"
  max_size                  = var.ecs_asg_max_size
  min_size                  = var.ecs_asg_min_size
  desired_capacity          = var.ecs_asg_desired_size
  vpc_zone_identifier       = [for s in aws_subnet.public: s.id]
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.env}-ecs-instance"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "${var.project_name}-${var.env}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.cluster.name
  capacity_providers = [
    aws_ecs_capacity_provider.ec2.name
  ]
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
  }
}

# Task definition (EC2) with three containers
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.env}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = local.task_execution_role_arn
  task_role_arn            = local.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "api-gateway"
      image     = "${aws_ecr_repository.api_gateway.repository_url}:${var.image_tag_api}"
      essential = true
      portMappings = [{
        containerPort = var.app_container_port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api-gateway"
        }
      }
      environment = [
        { name = "PRODUCT_SERVICE_URL",   value = "http://localhost:8001" },
        { name = "INVENTORY_SERVICE_URL", value = "http://localhost:8002" }
      ]
    },
    {
      name      = "product-service"
      image     = "${aws_ecr_repository.product.repository_url}:${var.image_tag_product}"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "product-service"
        }
      }
      environment = []
    },
    {
      name      = "inventory-service"
      image     = "${aws_ecr_repository.inventory.repository_url}:${var.image_tag_inventory}"
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "inventory-service"
        }
      }
      environment = []
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "${var.project_name}-${var.env}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "api-gateway"
    container_port   = var.app_container_port
  }

  network_configuration {
    subnets         = [for s in aws_subnet.public: s.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.http,
    aws_ecs_cluster_capacity_providers.this
  ]
}

