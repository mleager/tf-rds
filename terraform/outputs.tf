output "bastion_id" {
  value = var.enable_bastion ? aws_instance.bastion[0].id : null
}

output "ami_short_name" {
  value = split("-", data.aws_ami.linux.name)[0]
}

output "script" {
  value = local.setup_script
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

