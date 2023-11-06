/* RDS */

output "db_address" {
  value = aws_db_instance.lanchonete_rds.address
}

output "db_name" {
  value = aws_db_instance.lanchonete_rds.db_name
}
