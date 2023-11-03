/* RDS */

output "db_address" {
  value = aws_db_instance.lanchonete_rds.address
}

output "db_name" {
  value = aws_db_instance.lanchonete_rds.db_name
}

/* EKS */

output "cluster_id" {
  value       = aws_eks_cluster.lanchonete.id
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.lanchonete.endpoint
}
