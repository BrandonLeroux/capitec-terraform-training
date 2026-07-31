output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.eks-cluster.name
}

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.eks-cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server."
  value       = aws_eks_cluster.eks-cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded CA data for connecting to the cluster."
  value       = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "The cluster security group created and managed by EKS."
  value       = aws_eks_cluster.eks-cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role."
  value       = aws_iam_role.this["cluster"].arn
}

output "node_role_arn" {
  description = "ARN of the managed node group IAM role."
  value       = aws_iam_role.this["node"].arn
}

output "node_group_name" {
  description = "Name of the managed node group."
  value       = aws_eks_node_group.eks-ng.node_group_name
}

output "subnet_ids" {
  description = "IDs of the subnets created for the cluster."
  value       = module.subnet.subnet_ids
}
