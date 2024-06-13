resource "aws_security_group" "ansible_rules" {
    name = "ansible_rules"
    description = "Allow SSH inbound traffic"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTP"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTPs"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "k8s_nodes" {
    name = "k8s_nodes"
    description = "Allow all traffic between nodes in the cluster"
    vpc_id = module.vpc.vpc_id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTP"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      description = "HTTPs"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg-k8s-nodes"
    }
}
resource "aws_security_group" "k8s_masters" {
    name = "k8s_masters"
    description = "Allow all traffic between master nodes in the cluster"
    vpc_id = module.vpc.vpc_id

    ingress {
        #Kubernetes API server
        from_port   = 6443
        to_port     = 6443
        protocol    = "tcp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    ingress {
        #etcd server client API
        from_port   = 2379
        to_port     = 2380
        protocol    = "tcp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    ingress {
        #Kubelet API
        from_port   = 10250
        to_port     = 10250
        protocol    = "tcp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    ingress {
        #kube-scheduler
        from_port   = 10259
        to_port     = 10259
        protocol    = "tcp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    ingress {
        #kube-controller-manager
        from_port   = 10257
        to_port     = 10257
        protocol    = "tcp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    tags = {
        Name = "sg-k8s-masters"
    }
}
resource "aws_security_group" "k8s_workers" {
    name = "k8s_workers"
    description = "Allow all traffic between worker nodes in the cluster"
    vpc_id = module.vpc.vpc_id

    ingress {
        #Kubelet API
        from_port   = 10250
        to_port     = 10250
        protocol    = "tcp"
        cidr_blocks = ["${var.cidr_vpc}"]
    }

    ingress {
        #NodePort Services
        from_port   = 30000
        to_port     = 32767
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "sg-k8s-workers"
    }
}