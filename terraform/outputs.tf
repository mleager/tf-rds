output "bastion_id" {
  value = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "rds_instance_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_name" {
  value = aws_db_instance.postgres.db_name
}

output "db_username" {
  value = aws_db_instance.postgres.username
}

