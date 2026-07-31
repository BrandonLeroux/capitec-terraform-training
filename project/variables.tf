variable "region" {
  type        = string
  description = "AWS region to deploy into."
  default     = "af-south-1"
}

variable "participant" {
  type        = string
  description = "Trainee key into the subnet allocation table (see participants.tf)."
  default     = "brandon_le_roux"
  validation {
    condition     = contains(keys(local.subnet_allocation), var.participant)
    error_message = "participant must be one of the keys defined in local.subnet_allocation."
  }
}

variable "surname" {
  type        = string
  description = "Surname component of the resource name prefix."
  default     = "leroux"
}

variable "initials" {
  type        = string
  description = "Initials component of the resource name prefix."
  default     = "bap"
}

variable "environment" {
  type        = string
  description = "Environment name used in resource names and tags (e.g. dev, int, prod)."
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Owner tag applied to all resources via provider default_tags."
  default     = "bap le roux"
}

variable "vpc_id" {
  type        = string
  description = "ID of the existing VPC to deploy into."
  default     = "vpc-04afeafc288c397af"
}

variable "rt_id" {
  type        = string
  description = "ID of the existing route table to associate subnets with."
  default     = "rtb-023fc1846d75af176"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones to spread the cluster across."
  default     = ["af-south-1a", "af-south-1b", "af-south-1c"]
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
