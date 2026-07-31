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

variable "resource" {
  type    = string
  default = "s3"
}

variable "bucket_count" {
  type    = number
  default = 3
}

variable "envs" {
  type    = list(string)
  default = ["dev", "int", "qa", "prod"]
}
