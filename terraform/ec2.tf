data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  subnet_id = module.vpc.public_subnets[0]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "launch_template" {
  name                   = "bastion-template-${var.environment}"
  image_id               = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.bastion.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  user_data = base64encode(templatefile("${path.module}/script/psql-setup.sh", {
    db_password = data.aws_ssm_parameter.db_password.name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-${var.environment}"
      Role        = "bastion"
      CreatedBy   = "terraform"
      CreatedDate = "${timestamp()}"
    }
  }
}

