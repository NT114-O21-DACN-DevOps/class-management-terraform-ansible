variable "region" {
  default = "ap-southeast-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "ami_id" {
  type = string
  default = "ami-003c463c8207b4dfa" // Ubuntu 24.04
}

variable "master_node_count" {
  type = number
  default = 3
}

variable "worker_node_count" {
  type = number
  default = 3
}

variable "ssh_user" {
  type = string
  default = "ubuntu"
}

variable "master_instance_type" {
  type = string
  default = "t2.medium"
}

variable "worker_instance_type" {
  type = string
  default = "t2.large"
}

variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  type = list(string)
  default = ["10.0.1.0/24"]
}