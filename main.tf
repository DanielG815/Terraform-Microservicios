provider "aws" {
  region = "us-east-1"
}

# VPC por defecto
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "microservicios_sg" {
  name        = "microservicios-sg"
  description = "Permitir acceso a los microservicios en 5000, 5001, 5002 y SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Clima"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Temblor"
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Comportamiento"
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

# Instancia EC2
resource "aws_instance" "microservicios" {
  ami           = "ami-0c2b8ca1dad447f8a" # Amazon Linux 2 en us-east-1
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.microservicios_sg.id]

  tags = {
    Name = "microservicios-docker"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -xe

              # Actualizar paquetes
              yum update -y

              # Instalar Docker
              amazon-linux-extras enable docker
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              # Instalar docker-compose (v2.20.3 estable)
              curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Crear carpeta para la app
              mkdir -p /home/ec2-user/app
              cat <<EOT > /home/ec2-user/app/docker-compose.yml
              version: "3.9"
              services:
                clima:
                  image: axelbernales/clima:latest
                  ports:
                    - "5000:5000"
                temblor:
                  image: axelbernales/temblor:latest
                  ports:
                    - "5001:5000"
                comportamiento:
                  image: axelbernales/comportamiento:latest
                  ports:
                    - "5002:5000"
              EOT

              # Levantar los servicios
              cd /home/ec2-user/app
              /usr/local/bin/docker-compose up -d

              EOF
}

