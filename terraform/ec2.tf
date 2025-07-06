data "aws_ami" "linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = var.use_al2023 ? ["al2023-ami-2023*"] : ["ubuntu/images/hvm-ssd*ubuntu-noble*"]
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

locals {
  al2023_path = "${path.module}/script/psql-setup-al2023.sh"
  ubuntu_path = "${path.module}/script/psql-setup-ubuntu.sh"

  setup_script = var.use_al2023 ? local.al2023_path : local.ubuntu_path
}

resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "launch_template" {
  name          = "bastion-template-${var.environment}"
  image_id      = data.aws_ami.linux.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  network_interfaces {
    subnet_id                   = module.vpc.public_subnets[0]
    security_groups             = [aws_security_group.bastion.id]
    associate_public_ip_address = true
  }

  # user_data = base64encode(
  #   templatefile(var.use_al2023 ?
  #     "${path.module}/script/psql-setup-al2023.sh" :
  #     "${path.module}/script/psql-setup-ubuntu.sh", {
  #       db_password = data.aws_ssm_parameter.db_password.name
  #   })
  # )

  user_data = base64encode(templatefile(local.setup_script, {
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

