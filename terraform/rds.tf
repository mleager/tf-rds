data "aws_ssm_parameter" "db_password" {
  name            = "/${var.environment}/db/password"
  with_decryption = true
}

resource "aws_db_instance" "postgres" {
  db_name              = "postgresdb"
  engine               = "postgres"
  engine_version       = "17.5"
  instance_class       = var.rds_instance_type
  username             = "postgres"
  password             = data.aws_ssm_parameter.db_password.value
  parameter_group_name = "default.postgres17"

  db_subnet_group_name = aws_db_subnet_group.default.name

  allocated_storage = 10
  storage_type      = "gp2"

  multi_az            = false
  skip_final_snapshot = true
  apply_immediately   = true

  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "${var.project_name}-${var.environment}-subnet-group"
  description = "Default subnet group for ${var.environment}"

  subnet_ids = module.vpc.private_subnets
}

