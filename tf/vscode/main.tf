# VSCode Terraform
##################
#
# This will create a new shell suitable for use with VSCode
terraform {
  required_providers {
    aws = "~> 3"
  }
}

variable "region" {
  type        = string
  default     = "us-west-2"
  description = "Region"
}

variable "az" {
  type        = string
  default     = "us-west-2b"
  description = "Availability Zone"
}

variable "vpc" {
  type        = string
  default     = "vpc-0bee7247d98ae6831"
  description = "VPC ID"
}

provider "aws" {
  region = var.region
}

data "aws_subnet_ids" "vscode" {
  vpc_id = var.vpc
  filter {
    name   = "availability-zone"
    values = [var.az]
  }
}

# output "subnet_ids" {
#   value = data.aws_subnet_ids.vscode
# }

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-groovy-20.10-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# output "aws_ami" {
#     value = data.aws_ami.ubuntu
# }

resource "aws_ebs_volume" "vscode" {
  availability_zone = var.az
  size              = 25
  type              = "gp3"
}

resource "aws_key_pair" "vscode" {
  key_name   = "vscode"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "vscode" {
  name        = "vscode"
  description = "Control traffic to VSCode instance"
  vpc_id      = var.vpc

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: Close this down
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_spot_instance_request" "vscode" {
  ami                  = data.aws_ami.ubuntu.id
  spot_price           = "0.085"
  spot_type            = "one-time"
  wait_for_fulfillment = true

  key_name                    = aws_key_pair.vscode.id
  instance_type               = "c5.xlarge"
  availability_zone           = var.az
  associate_public_ip_address = true
  subnet_id                   = sort(data.aws_subnet_ids.vscode.ids)[0]
  vpc_security_group_ids      = [aws_security_group.vscode.id]

  tags = {
    Name = "VSCode"
  }
}

# output "vscode" {
#   value = aws_spot_instance_request.vscode
# }

resource "aws_volume_attachment" "vscode" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.vscode.id
  instance_id = aws_spot_instance_request.vscode.spot_instance_id
}

data "aws_route53_zone" "shakefu_net" {
  name = "shakefu.net"
}

resource "aws_route53_record" "shakefu_net" {
  zone_id = data.aws_route53_zone.shakefu_net.zone_id
  name    = "shakefu.net"
  type    = "A"
  ttl     = "5"
  records = [aws_spot_instance_request.vscode.public_ip]
}