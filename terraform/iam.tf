data "aws_iam_policy_document" "assume" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_describe" {
  version = "2012-10-17"

  statement {
    effect    = "Allow"
    actions   = ["rds:Describe*"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = [var.region]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "ssm-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "rds_describe_policy" {
  name        = "rds-describe-policy"
  description = "Allows SSM to describe RDS instances."
  policy      = data.aws_iam_policy_document.rds_describe.json
}

resource "aws_iam_role_policy_attachment" "rds_describe" {
  role       = aws_iam_role.ssm_role.id
  policy_arn = aws_iam_policy.rds_describe_policy.arn
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-profile"
  role = aws_iam_role.ssm_role.id
}

