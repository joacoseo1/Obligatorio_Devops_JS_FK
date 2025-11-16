resource "aws_ecr_repository" "api_gateway" {
  count                = 1
  name                 = "${var.project_name}-api-gateway"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

resource "aws_ecr_repository" "product" {
  count                = 1
  name                 = "${var.project_name}-product-service"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

resource "aws_ecr_repository" "inventory" {
  count                = 1
  name                 = "${var.project_name}-inventory-service"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

locals {
  ecr_api_repo_url       = aws_ecr_repository.api_gateway[0].repository_url
  ecr_product_repo_url   = aws_ecr_repository.product[0].repository_url
  ecr_inventory_repo_url = aws_ecr_repository.inventory[0].repository_url
}

