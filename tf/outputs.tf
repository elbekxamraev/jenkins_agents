output "instances_ips" {
    value = [for i in aws_instance.instances : i.public_ip ] 
}
output "ansible_ip" {
  value = aws_instance.ansible.public_ip
}


