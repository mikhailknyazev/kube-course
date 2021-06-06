terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.40.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      owner = "kube-course"
    }
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = <<-EOF
              #!/bin/bash
              echo '<!DOCTYPE html> <body>Terraform and AWS</body>' > index.html
              nohup busybox httpd -f -p 80 &
              EOF

  tags = {
    Name = "hello-world-web"
  }
}

resource "aws_security_group" "web" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

