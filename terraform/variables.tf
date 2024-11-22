variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3a.medium"
}

variable "ubuntu_ami" {
  description = "Ubuntu 22.04 AMI ID for the region"
  default     = "ami-0d64bb532e0502c46" # Eu-West-1 için örnek AMI
}

variable "key_name" {
  description = "AWS key pair name"
  default     = "case"
}
