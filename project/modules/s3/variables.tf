variable "prefix" {
  type        = string
  description = "Name prefix for the buckets."
}

variable "environment" {
  type        = string
  description = "Environment name used in bucket names and tags."
  default     = "dev"
}

variable "owner" {
  type        = string
  description = "Owner tag applied to the buckets."
  default     = "bap le roux"
}

variable "resource" {
  type        = string
  description = "Resource keyword used in the bucket name."
  default     = "s3"
}

variable "bucket_count" {
  type        = number
  description = "Number of buckets to create with count."
  default     = 3
}

variable "envs" {
  type        = list(string)
  description = "Environment keys to create one bucket per, using for_each."
  default     = ["dev", "int", "qa", "prod"]
}
