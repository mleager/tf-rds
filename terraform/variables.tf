variable "project_name" {
  type        = string
  default     = "tf-rds"
  description = "The name of the Github Repo"
}

variable "environment" {
  type        = string
  default     = "development"
  description = "Environment name (development, staging, production)"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "enable_bastion" {
  type        = bool
  default     = true
  description = "Enable bastion host"
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The EC2 instance type"
}

variable "rds_instance_type" {
  type        = string
  default     = "db.t4g.micro"
  description = "The RDS instance class to use"
}

