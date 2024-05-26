variable "region" {
  default = "ap-southeast-1"
}

variable "ami_id" {
  type = string
  default = "ami-0be48b687295f8bd6" // Ubuntu 22.04
}

variable "master_node_count" {
  type = number
  default = 1
}

variable "worker_node_count" {
  type = number
  default = 2
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
  default = "t2.medium"
}