terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
    region= "us-east-1"
}
resource "aws_vpc" "my-vpc" {
  cidr_block= "10.0.0.0/16"
}
resource "aws_subnet" "subnet" {
   vpc_id     = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"

}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
}
resource "aws_instance" "instances" {
    count=3
    associate_public_ip_address=true
    subnet_id = aws_subnet.subnet.id
  ami= data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.security.id]
  tags = {
    name= "${count.index}-instance"
  }
}
resource "aws_security_group" "security" {
    name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id
  
   
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
output "instances_ips" {
  value = aws_instance.instances[*].public_ip
}
