resource "aws_ecr_repository" "api_gateway" {
  name                 = "${var.project_name}-api-gateway"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

resource "aws_ecr_repository" "product" {
  name                 = "${var.project_name}-product-service"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

resource "aws_ecr_repository" "inventory" {
  name                 = "${var.project_name}-inventory-service"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

