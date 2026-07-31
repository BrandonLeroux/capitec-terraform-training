variable "vpc_id" {
  type        = string
  description = "ID of the VPC to create the subnets in."
}

variable "rt_id" {
  type        = string
  description = "ID of the route table to associate the subnets with."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones to create subnets in (one subnet per AZ)."
  default     = ["af-south-1a", "af-south-1b", "af-south-1c"]
}

variable "cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks, one per availability zone, in the same order as availability_zones."
}

variable "prefix" {
  type        = string
  description = "Name prefix for the subnets."
}

variable "environment" {
  type        = string
  description = "Environment name used in subnet names (e.g. dev, int, prod)."
  default     = "dev"
}
