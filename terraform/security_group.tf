resource "aws_security_group" "bastion" {
  name        = "Bastion"
  description = "Allow Bastion Host to connect to the RDS instance"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "Bastion Security Group"
  }
}

resource "aws_vpc_security_group_egress_rule" "https_egress" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_egress_to_rds" {
  security_group_id            = aws_security_group.bastion.id
  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "rds" {
  name        = "RDS Security  Group"
  description = "Allow Incoming traffic from the Bastion Host"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_to_bastion" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_egress" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

