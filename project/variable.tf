variable "env" {
  type    = list(string)
  default = ["dev", "int", "qa", "prod"]
}

variable "surname" {
  type    = string
  default = "leroux"
}

variable "initials" {
  type    = string
  default = "bap"
}

variable "resource" {
  type    = string
  default = "s3"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "bap le roux"
}

variable "vpc_id" {
  type    = string
  default = "vpc-04afeafc288c397af"
}

variable "rt_id" {
  type    = string
  default = "rtb-023fc1846d75af176"
}

variable "availability_zones" {
  type    = list(string)
  default = ["af-south-1a", "af-south-1b", "af-south-1c"]
}

variable "bucket_count" {
  type    = number
  default = 3
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