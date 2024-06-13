resource "local_file" "ansible_inventory" {
    content = templatefile("${path.root}/templates/inventory.tftpl",
        {
            masters-dns = aws_instance.masters.*.private_dns,
            masters-ip  = aws_instance.masters.*.private_ip,
            masters-id  = aws_instance.masters.*.id,
            workers-dns = aws_instance.workers.*.private_dns,
            workers-ip  = aws_instance.workers.*.private_ip,
            workers-id  = aws_instance.workers.*.id
            ansible-dns = aws_instance.ansible.private_dns,
            ansible-ip  = aws_instance.ansible.private_ip,
            ansible-id  = aws_instance.ansible.id
        }
    )
    filename = "${path.root}/inventory"
}

# Wait for Ansible user data to complete
resource "time_sleep" "wait_for_ansible" {
    depends_on = [aws_instance.ansible]
    create_duration = "200s"
  
    triggers = {
        "always_run" = timestamp()
    }
}

resource "null_resource" "provisioner" {
    depends_on = [ 
        local_file.ansible_inventory,
        time_sleep.wait_for_ansible,
        aws_instance.ansible
    ]

    triggers = {
        "always_run" = timestamp()
    }

    provisioner "file" {
        source = "${path.root}/inventory"
        destination = "/home/ubuntu/inventory"

        connection {
            type = "ssh"
            host = aws_instance.ansible.public_ip
            user = var.ssh_user
            private_key = tls_private_key.ssh.private_key_pem
            agent = false
        }
    }
}

resource "local_file" "ansible_vars_file" {
    content = <<-DOC
            master_lb: ${aws_lb.k8s_masters_lb.dns_name}
        DOC
    filename = "ansible/ansible_vars_file.yml"
}

resource "null_resource" "copy_ansible_playbooks" {
  depends_on = [
        null_resource.provisioner,
        time_sleep.wait_for_ansible,
        aws_instance.ansible,
        local_file.ansible_vars_file
    ]

  triggers = {
    "always_run" = timestamp()
  }

  provisioner "file" {
      source = "${path.root}/ansible/ansible_vars_file.yml"
      destination = "/home/ubuntu/ansible_vars_file.yml"

      connection {
        type = "ssh"
        host = aws_instance.ansible.public_ip
        user = var.ssh_user
        private_key = tls_private_key.ssh.private_key_pem
        agent = false
      }
  }
}

resource "null_resource" "copy_playbooks" {
    depends_on = [ 
        null_resource.provisioner,
        time_sleep.wait_for_ansible,
        aws_instance.ansible,
        local_file.ansible_vars_file
    ]

    triggers = {
        "always_run" = timestamp()
    }

    provisioner "file" {
        source = "${path.root}/ansible/playbook.yml"
        destination = "/home/ubuntu/playbook.yml"

        connection {
            type = "ssh"
            host = aws_instance.ansible.public_ip
            user = var.ssh_user
            private_key = tls_private_key.ssh.private_key_pem
            agent = false
        }
    }
}

resource "null_resource" "run_ansible" {
    depends_on = [
        null_resource.provisioner,
        null_resource.copy_playbooks,
        aws_instance.masters,
        aws_instance.workers,
        module.vpc,
        aws_instance.ansible,
        time_sleep.wait_for_ansible
    ]

    triggers = {
        "always_run" = timestamp()
    }

    connection {
        type = "ssh"
        host = aws_instance.ansible.public_ip
        user = var.ssh_user
        private_key = tls_private_key.ssh.private_key_pem
        agent = false
    }

    provisioner "remote-exec" {
        inline = [
            "echo 'Running Ansible'",
            "sleep 180 && ansible-playbook -i /home/ubuntu/inventory /home/ubuntu/playbook.yml"
        ]
    }
}