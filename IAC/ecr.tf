data "aws_ecr_repository" "api_gateway_existing" {
  count = var.existing_ecr_api_repo_name != null ? 1 : 0
  name  = var.existing_ecr_api_repo_name
}

resource "aws_ecr_repository" "api_gateway" {
  count                = var.existing_ecr_api_repo_name != null ? 0 : 1
  name                 = "${var.project_name}-api-gateway"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

data "aws_ecr_repository" "product_existing" {
  count = var.existing_ecr_product_repo_name != null ? 1 : 0
  name  = var.existing_ecr_product_repo_name
}

resource "aws_ecr_repository" "product" {
  count                = var.existing_ecr_product_repo_name != null ? 0 : 1
  name                 = "${var.project_name}-product-service"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

data "aws_ecr_repository" "inventory_existing" {
  count = var.existing_ecr_inventory_repo_name != null ? 1 : 0
  name  = var.existing_ecr_inventory_repo_name
}

resource "aws_ecr_repository" "inventory" {
  count                = var.existing_ecr_inventory_repo_name != null ? 0 : 1
  name                 = "${var.project_name}-inventory-service"
  image_tag_mutability = "MUTABLE"
  tags = { Environment = var.env }
}

locals {
  ecr_api_repo_url       = var.existing_ecr_api_repo_name != null ? data.aws_ecr_repository.api_gateway_existing[0].repository_url : aws_ecr_repository.api_gateway[0].repository_url
  ecr_product_repo_url   = var.existing_ecr_product_repo_name != null ? data.aws_ecr_repository.product_existing[0].repository_url : aws_ecr_repository.product[0].repository_url
  ecr_inventory_repo_url = var.existing_ecr_inventory_repo_name != null ? data.aws_ecr_repository.inventory_existing[0].repository_url : aws_ecr_repository.inventory[0].repository_url
}

