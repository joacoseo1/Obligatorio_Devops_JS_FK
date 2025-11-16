resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.env}-alb-sg"
  description = "Allow HTTP to ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "${var.project_name}-${var.env}-ecs-sg"
  description = "Tasks security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = var.app_container_port
    to_port         = var.app_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow ALB to reach tasks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for ECS EC2 instances (container instances)
resource "aws_security_group" "ecs_instances_sg" {
  name        = "${var.project_name}-${var.env}-ecs-instances-sg"
  description = "ECS container instances"
  vpc_id      = aws_vpc.this.id

  # No inbound needed by default (tasks use awsvpc and are reached via their ENIs)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

