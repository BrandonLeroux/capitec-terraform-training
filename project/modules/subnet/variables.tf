variable "vpc_id" {
  type = string
}

variable "rt_id" {
  type = string
}

variable "availability_zones" {
  type    = list(string)
  default = ["af-south-1a", "af-south-1b", "af-south-1c"]
}

variable "cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks, one per availability zone, in the same order as availability_zones"
}

variable "prefix" {
  type    = string
  default = "lerouxbap"
}

variable "environment" {
  type    = string
  default = "dev"
}

