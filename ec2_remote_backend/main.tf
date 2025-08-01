terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "rs_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "rs_vpc"
  }
}

resource "aws_subnet" "rs_subnet" {
  vpc_id            = aws_vpc.rs_vpc.id
  cidr_block        = var.sub_cidr
  availability_zone = var.az

  tags = {
    Name = "rs_subnet"
  }
}

resource "aws_internet_gateway" "rs_IGW" {
  vpc_id = aws_vpc.rs_vpc.id

  tags = {
    Name = "rs_IGW"
  }
}

resource "aws_route_table" "rs_route_table" {
  vpc_id = aws_vpc.rs_vpc.id

  route {
    gateway_id = aws_internet_gateway.rs_IGW.id
    cidr_block = var.route_cidr
  }

  tags = {
    Name = "rs_route_table"
  }
}

resource "aws_route_table_association" "rs_rt_asso" {
  route_table_id = aws_route_table.rs_route_table.id
  subnet_id      = aws_subnet.rs_subnet.id
}

resource "aws_security_group" "rs_sg" {
  vpc_id = aws_vpc.rs_vpc.id

  ingress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = var.sg_protocol
    cidr_blocks = [var.route_cidr]
  }

  egress {
    from_port   = var.from_port
    to_port     = var.to_port
    protocol    = var.sg_protocol
    cidr_blocks = [var.route_cidr]
  }

  tags = {
    Name = "rs_sg"
  }
}

resource "tls_private_key" "generate_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "rs_keypair" {
  public_key = tls_private_key.generate_key.public_key_openssh

  tags = {
    Name = "rs_keypair"
  }
}

data "aws_ami" "main_amzn_lnx" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_instance" "rs_ec2" {
  ami                         = data.aws_ami.main_amzn_lnx.id
  instance_type               = var.inst_type
  key_name                    = aws_key_pair.rs_keypair.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.rs_sg.id]
  subnet_id                   = aws_subnet.rs_subnet.id

  tags = {
    Name = "rs_ec2"
  }
}
