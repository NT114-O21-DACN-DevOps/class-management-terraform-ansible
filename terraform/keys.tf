resource "tls_private_key" "ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "local_file" "k8s_ssh_key" {
    filename = "${path.module}/k8s-ssh-key.pem"
    file_permission = "600"
    content = tls_private_key.ssh.private_key_pem
}

resource "aws_key_pair" "k8s_ssh" {
    key_name = "k8s_ssh"
    public_key = tls_private_key.ssh.public_key_openssh
}