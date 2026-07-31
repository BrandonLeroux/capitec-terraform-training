variable "availability_zones" {
  type    = list(string)
  default = ["af-south-1a", "af-south-1b", "af-south-1c"]
}

variable "vpc_id" {
  type = string
}

variable "rt_id" {
  type = string
}

variable "cidr_blocks" {
  type        = list(string)
  description = "Subnet CIDR blocks, one per availability zone (same order as availability_zones)."
}

variable "prefix" {
  type    = string
  default = "lerouxbap"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster."
  default     = "1.35"
}

variable "authentication_mode" {
  type        = string
  description = "EKS cluster authentication mode (API, API_AND_CONFIG_MAP, or CONFIG_MAP)."
  default     = "API"
}

variable "cluster_admin_policy_arn" {
  type        = string
  description = "EKS access policy granted to the deploying principal."
  default     = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}

variable "node_policy_arns" {
  type = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ]
}

variable "instance_types" {
  type        = list(string)
  description = "Instance types for the managed node group."
  default     = ["t3.micro"]
}

variable "node_scaling" {
  type = object({
    min_size     = number
    desired_size = number
    max_size     = number
  })
  description = "Node group scaling configuration."
  default = {
    min_size     = 1
    desired_size = 2
    max_size     = 3
  }
}

variable "node_max_unavailable" {
  type        = number
  description = "Max nodes unavailable during a node group update."
  default     = 1
}

variable "node_security_group_ingress" {
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  description = "Ingress rules to add to the cluster security group, keyed by a stable name."
  default = {
    nodeport = {
      description = "Allow inbound access to nginx NodePort service"
      from_port   = 30007
      to_port     = 30007
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
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
