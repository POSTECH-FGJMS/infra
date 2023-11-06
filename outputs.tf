/* RDS */

output "db_address" {
  value = aws_db_instance.lanchonete_rds.address
}

output "db_name" {
  value = aws_db_instance.lanchonete_rds.db_name
}

/* EKS */

output "cluster_endpoint" {
  description = "The endpoint for your EKS Kubernetes API."
  value       = aws_eks_cluster.lanchonete_cluster.endpoint
}