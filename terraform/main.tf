provider "aws" {
  region = var.aws_region
}

resource "aws_security_group" "app_sg" {
  name        = "foodexpress-app-sg"
  description = "Allow SSH and app port"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
  volume_size = 20
}

  tags = {
    Name = "FoodExpress-App"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    chmod 666 /var/run/docker.sock
  EOF
}