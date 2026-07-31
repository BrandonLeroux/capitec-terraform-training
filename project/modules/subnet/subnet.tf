locals {
  subnets = {
    for idx, az in var.availability_zones : az => {
      index      = idx
      cidr_block = var.cidr_blocks[idx]
    }
  }
}

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-az${each.value.index + 1}-subnet-${var.environment}"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  subnet_id      = each.value.id
  route_table_id = var.rt_id
}
