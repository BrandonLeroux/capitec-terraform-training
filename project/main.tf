# CI test: verify per-environment plan on PRs into int and prod.
module "eks" {
  source = "./modules/eks"

  prefix             = local.prefix
  environment        = var.environment
  capacity_type      = var.capacity_type
  vpc_id             = var.vpc_id
  rt_id              = var.rt_id
  availability_zones = var.availability_zones
  cidr_blocks        = local.subnet_allocation[var.participant].subnets
}
