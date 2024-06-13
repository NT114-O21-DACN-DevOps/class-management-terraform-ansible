resource "aws_instance" "ansible" {
    ami = var.ami_id
    instance_type = "t2.medium"
    subnet_id = module.vpc.public_subnets[0]
    associate_public_ip_address = "true"
    vpc_security_group_ids = [aws_security_group.ansible_rules.id]
    key_name = aws_key_pair.k8s_ssh.key_name
    user_data = <<-EOF
                #!/bin/bash
                echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
                systemctl reload sshd
                echo "${tls_private_key.ssh.private_key_pem}" >> /home/ubuntu/.ssh/id_rsa
                chown ubuntu /home/ubuntu/.ssh/id_rsa
                chgrp ubuntu /home/ubuntu/.ssh/id_rsa
                chmod 600 /home/ubuntu/.ssh/id_rsa
                echo "Starting ansible install"
                echo "Add personal package archive for ansible"
                sudo apt-get update -y
                sudo apt-get install -y software-properties-common
                sudo add-apt-repository --yes --update ppa:ansible/ansible
                sudo apt-get install ansible -y
                echo "Ansible installed"
                EOF
    tags = {
        Name = "Ansible"
    }
    root_block_device {
       volume_size = 10  // Tăng dung lượng ổ đĩa lên 10GB
    }
}

resource "aws_instance" "masters" {
    count = var.master_node_count
    ami = var.ami_id
    instance_type = var.master_instance_type
    subnet_id = module.vpc.public_subnets[0]
    key_name = aws_key_pair.k8s_ssh.key_name
    vpc_security_group_ids = [aws_security_group.k8s_nodes.id, aws_security_group.k8s_masters.id]

    tags = {
        Name = format("Master-%02d", count.index + 1)
    }
    root_block_device {
       volume_size = 20  // Tăng dung lượng ổ đĩa lên 20GB
    }
}
resource "aws_instance" "workers" {
    count = var.worker_node_count
    ami = var.ami_id
    instance_type = var.worker_instance_type
    subnet_id = module.vpc.public_subnets[0]
    key_name = aws_key_pair.k8s_ssh.key_name
    vpc_security_group_ids = [aws_security_group.k8s_nodes.id, aws_security_group.k8s_workers.id]

    tags = {
        Name = format("Worker-%02d", count.index + 1)
    }
    root_block_device {
       volume_size = 20  // Tăng dung lượng ổ đĩa lên 20GB
    }
}