resource "aws_vpc" "this" {
  count                = var.use_existing_vpc ? 0 : 1
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  count  = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.this[0].id
  tags = { Name = "${var.project_name}-${var.env}-igw" }
}

resource "aws_subnet" "public" {
  count                   = var.use_existing_vpc ? 0 : length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.project_name}-${var.env}-public-${count.index + 1}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_route_table" "public" {
  count = var.use_existing_vpc ? 0 : 1
  vpc_id = aws_vpc.this[0].id
  tags = { Name = "${var.project_name}-${var.env}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.use_existing_vpc ? 0 : length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route" "internet_access" {
  count                  = var.use_existing_vpc ? 0 : 1
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

locals {
  vpc_id = var.use_existing_vpc ? var.existing_vpc_id : aws_vpc.this[0].id
  public_subnet_ids = var.use_existing_vpc ? var.existing_public_subnet_ids : [for s in aws_subnet.public : s.id]
}

