output "vpc_id" {
  value = aws_vpc.this.id
}

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "ecr_api_gateway_repo" {
  value = aws_ecr_repository.api_gateway.repository_url
}

output "ecr_product_repo" {
  value = aws_ecr_repository.product.repository_url
}

output "ecr_inventory_repo" {
  value = aws_ecr_repository.inventory.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.service.name
}