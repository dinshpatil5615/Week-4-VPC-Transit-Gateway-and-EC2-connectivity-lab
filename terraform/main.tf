terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "Existing EC2 key pair name for ssh"
  type        = string
  default     = "week4-lab"
}

variable "my_ip" {
  description = "Your IP in CIDR form, For restricting SSH"
  type        = string
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  user_data_template = <<-EOF
    #!/bin/bash
    SERVICE_NAME="${"$"}1"
    mkdir -p /var/www
    echo "Hello from ${"$"}SERVICE_NAME" > /var/www/index.html
    cd /var/www && nohup python3 -m http.server 80 &
  EOF
}

