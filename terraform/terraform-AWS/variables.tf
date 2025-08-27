variable "aws_region" {
  type        = string
  default     = "eu-west-3"
  description = "AWS region"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "EC2 instance type"
}

variable "admin_username" {
  type        = string
  default     = "admin"
  description = "Admin username for the EC2 instance"
}

variable "key_name" {
  type        = string
  description = "Name of the AWS key pair"
  default     = "traefik-key"
}