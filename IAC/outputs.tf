output "vpc_id" {
  value = local.vpc_id
}

output "alb_dns_name" {
  value = var.existing_alb_name != null ? data.aws_lb.existing[0].dns_name : aws_lb.alb[0].dns_name
}

output "ecr_api_gateway_repo" {
  value = local.ecr_api_repo_url
}

output "ecr_product_repo" {
  value = local.ecr_product_repo_url
}

output "ecr_inventory_repo" {
  value = local.ecr_inventory_repo_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}