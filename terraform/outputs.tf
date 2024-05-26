output "master_instance_ids" {
  value = aws_instance.masters[*].id
}

output "worker_instance_ids" {
  value = aws_instance.workers[*].id
}

output "master_instance_public_ips" {
  value = aws_instance.masters[*].public_ip
}

output "worker_instance_public_ips" {
  value = aws_instance.workers[*].public_ip
}

output "master_instance_private_ips" {
  value = aws_instance.masters[*].private_ip
}

output "worker_instance_private_ips" {
  value = aws_instance.workers[*].private_ip
}