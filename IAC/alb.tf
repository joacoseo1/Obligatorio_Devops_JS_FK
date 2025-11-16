resource "aws_lb" "alb" {
  count              = 1
  name               = "${var.project_name}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.public_subnet_ids
}

resource "aws_lb_target_group" "tg" {
  count      = 1
  name       = "${var.project_name}-${var.env}-tg"
  port       = var.app_container_port
  protocol   = "HTTP"
  vpc_id     = local.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
}

resource "aws_lb_listener" "http" {
  count             = 1
  load_balancer_arn = aws_lb.alb[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type            = "forward"
    target_group_arn = aws_lb_target_group.tg[0].arn
  }
}

locals {
  alb_arn = aws_lb.alb[0].arn
  tg_arn  = aws_lb_target_group.tg[0].arn
}
