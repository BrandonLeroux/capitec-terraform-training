output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Cluster security group managed by EKS."
  value       = module.eks.cluster_security_group_id
}

output "subnet_ids" {
  description = "Subnet IDs the cluster and node group run in."
  value       = module.eks.subnet_ids
}
