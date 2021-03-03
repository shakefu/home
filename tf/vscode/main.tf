# VSCode Terraform
##################
#
# This will create a new shell suitable for use with VSCode

##################
# Terraform basics

# TODO: Extract these when it's a module?
terraform {
  required_providers {
    aws = "~> 3"
  }
}

provider "aws" {
  region = var.region
}

###########
# Variables

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

###############
# Imported data

data "aws_subnet_ids" "vscode" {
  vpc_id = var.vpc
  filter {
    name   = "availability-zone"
    values = [var.az]
  }
}

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

data "aws_route53_zone" "shakefu_net" {
  name = "shakefu.net"
}

######################
# Persistent resources

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

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # TODO: Close this down
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

resource "aws_eip" "vscode" {
  vpc = true
  tags = {
    Name = "vscode"
  }
}

resource "aws_route53_record" "shakefu_net" {
  depends_on = [aws_eip.vscode]
  zone_id    = data.aws_route53_zone.shakefu_net.zone_id
  name       = "shakefu.net"
  type       = "A"
  ttl        = "5"
  records    = [aws_eip.vscode.public_ip]
}


#####################
# Ephemeral resources

resource "aws_spot_instance_request" "vscode" {
  ami                  = data.aws_ami.ubuntu.id
  spot_price           = "0.15"
  spot_type            = "one-time"
  wait_for_fulfillment = true

  key_name               = aws_key_pair.vscode.id
  instance_type          = "z1d.xlarge"
  availability_zone      = var.az
  subnet_id              = sort(data.aws_subnet_ids.vscode.ids)[0]
  vpc_security_group_ids = [aws_security_group.vscode.id]
  user_data              = file("userdata.sh")

  tags = {
    Name = "vscode"
  }
}

# output "vscode" {
#   value = aws_spot_instance_request.vscode
# }

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_spot_instance_request.vscode.spot_instance_id
  allocation_id = aws_eip.vscode.id
}

#########
# Volumes

locals {
  vols = [
    { name = "shakefu", size = 16, device = "/dev/sdg" },
  ]
  # vols = [
  #   ["etc", 1, "/dev/sdg"],
  #   ["home", 5, "/dev/sdh"],
  #   ["opt", 2, "/dev/sdi"],
  #   ["snap", 3, "/dev/sdj"],
  #   ["usr", 6, "/dev/sdk"],
  #   ["var", 4, "/dev/sdl"],
  # ]
}

resource "aws_ebs_volume" "vscode" {
  count             = length(local.vols)
  availability_zone = var.az
  size              = local.vols[count.index]["size"]
  type              = "gp3"
  tags = {
    Name = "vscode-${local.vols[count.index]["name"]}"
  }
}

resource "aws_volume_attachment" "vscode" {
  count       = length(local.vols)
  device_name = local.vols[count.index]["device"]
  volume_id   = aws_ebs_volume.vscode[count.index].id
  instance_id = aws_spot_instance_request.vscode.spot_instance_id
}
