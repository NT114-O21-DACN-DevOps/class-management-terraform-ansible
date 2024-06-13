module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    name = "k8s-vpc"
    cidr = var.cidr_vpc
    azs = var.availability_zones
    public_subnets = var.cidr_subnet
    # enable_nat_gateway = true
    # single_nat_gateway = true
    create_igw = true
    map_public_ip_on_launch = true

    tags = {
        Terraform = "true"
        Environment = "prod"
    }
}