resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"
    description = "Allow SSH inbound traffic"
    vpc_id = "vpc-0ddd4cd8dc7ce1477"

    ingress = {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "k8s_nodes" {
    name = "k8s_nodes"
    description = "Allow all traffic between nodes in the cluster"
    vpc_id = "vpc-0ddd4cd8dc7ce1477"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    ingress {
        from_port   = -1
        to_port     = -1
        protocol    = "icmp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "k8s_masters" {
    name = "k8s_masters"
    description = "Allow all traffic between master nodes in the cluster"
    vpc_id = "vpc-0ddd4cd8dc7ce1477"

    ingress {
        #Kubernetes API server
        from_port   = 6443
        to_port     = 6443
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    ingress {
        #etcd server client API
        from_port   = 2379
        to_port     = 2380
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    ingress {
        #Kubelet API
        from_port   = 10250
        to_port     = 10250
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    ingress {
        #kube-scheduler
        from_port   = 10259
        to_port     = 10259
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    ingress {
        #kube-controller-manager
        from_port   = 10257
        to_port     = 10257
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }
}
resource "aws_security_group" "k8s_workers" {
    name = "k8s_workers"
    description = "Allow all traffic between worker nodes in the cluster"
    vpc_id = "vpc-0ddd4cd8dc7ce1477"

    ingress {
        #Kubelet API
        from_port   = 10250
        to_port     = 10250
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }

    ingress {
        #NodePort Services
        from_port   = 30000
        to_port     = 32767
        protocol    = "tcp"
        cidr_blocks = ["172.31.0.0/16"]
    }
}