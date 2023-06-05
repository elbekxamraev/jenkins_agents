variable "ami" {
    type = string
    default = "ami-026ebd4cfe2c043b2"
}
variable "az" {
  type = string
  default = "us-east-1a"
}
variable "prefix" {
   type = map
   default = {
      sub-1 = {
         az = "us-east-1a"
         cidr = "10.0.198.0/24"
      }
      sub-2 = {
         az = "us-east-1b"
         cidr = "10.0.199.0/24"
      }
      sub-3 = {
         az = "us-east-1c"
         cidr = "10.0.200.0/24"
      }
   }
}
variable "ansible" {
  type = string
  default = "sub-1"
}