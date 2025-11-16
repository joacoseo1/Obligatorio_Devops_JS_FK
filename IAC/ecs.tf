resource "aws_ecs_cluster" "cluster" {
  name = "${var.project_name}-${var.env}-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.env}"
  retention_in_days = 14
}

# Task definition with three containers
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-${var.env}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

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
      environment = []
    },
    {
      name      = "product-service"
      image     = "${aws_ecr_repository.product.repository_url}:${var.image_tag_product}"
      essential = true
      # no hostPort; internal container only
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
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "api-gateway"
    container_port   = var.app_container_port
  }

  network_configuration {
    subnets          = [for s in aws_subnet.public: s.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  depends_on = [
    aws_lb_listener.http
  ]
}

