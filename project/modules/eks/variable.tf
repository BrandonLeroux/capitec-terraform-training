variable "availability_zones" {
  type    = list(string)
  default = ["af-south-1a", "af-south-1b", "af-south-1c"]
}

variable "vpc_id" {
  type    = string
  default = "vpc-04afeafc288c397af"
}

variable "rt_id" {
  type    = string
  default = "rtb-023fc1846d75af176"
}

variable "prefix" {
  type    = string
  default = "lerouxbap"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "bap le roux"
}

variable "node_policy_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

variable "participant" {
  type        = string
  description = "Key into local.subnet_allocation selecting which trainee's /24s to use."
  default     = "brandon_le_roux"
  validation {
    condition     = contains(keys(local.subnet_allocation), var.participant)
    error_message = "participant must be one of the keys defined in local.subnet_allocation."
  }
}

variable "capacity_type" {
  type        = string
  description = "Type of capacity to launch (ON_DEMAND or SPOT)"
  default     = "SPOT"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be either ON_DEMAND or SPOT."
  }
}
