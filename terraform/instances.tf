resource "aws_instance" "masters" {
    count = var.master_node_count
    ami = var.ami_id
    instance_type = var.master_instance_type
    key_name = aws_key_pair.k8s_ssh.key_name
    security_groups = [aws_security_group.k8s_nodes.id, aws_security_group.k8s_masters.id]

    tags = {
        Name = format("Master-%02d", count.index + 1)
    }
}
resource "aws_instance" "workers" {
    count = var.worker_node_count
    ami = var.ami_id
    instance_type = var.worker_instance_type
    key_name = aws_key_pair.k8s_ssh.key_name
    security_groups = [aws_security_group.k8s_nodes.id, aws_security_group.k8s_workers.id]

    tags = {
        Name = format("Worker-%02d", count.index + 1)
    }
}