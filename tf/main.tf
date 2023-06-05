terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
  }
}
resource "aws_vpc" "vpc" {
 cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "subnet" {
  for_each = var.prefix
  cidr_block = each.value["cidr"]
  vpc_id = aws_vpc.vpc.id
  availability_zone = each.value["az"]
  tags ={
    name = "${each.value["az"]}-sub"
  }
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "main"
  }
}
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}
resource "aws_route_table_association" "associate" {
    for_each =  var.prefix
   route_table_id = aws_route_table.route.id
    subnet_id = aws_subnet.subnet[each.key].id
}
provider "aws" {
  region= "us-east-1"
}
data "aws_availability_zones" "availability" {
    state = "available"
}
resource "aws_instance" "instances" {
  for_each = var.prefix
  ami= var.ami
  subnet_id = aws_subnet.subnet[each.key].id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  key_name = "key-demo"

}
resource "aws_instance" "ansible" {
   ami= var.ami
  subnet_id = aws_subnet.subnet[var.ansible].id
   instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
    key_name = "key-demo"
  tags = {
    name= "ansible"
  }
}
resource "aws_ebs_volume" "volume" {
  for_each = var.prefix
  availability_zone = each.value["az"]
  size              = 100

}
resource "aws_volume_attachment" "ebs_att" {
     for_each =  var.prefix
    device_name = "/dev/xvdf"
    volume_id = aws_ebs_volume.volume[each.key].id
    instance_id = aws_instance.instances[each.key].id
}
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    from_port        = 8080
    to_port          = 8080
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
    Name = "allow_ssh"
  }
}