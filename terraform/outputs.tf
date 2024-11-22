output "master_node_public_ip" {
  value = aws_instance.master_node.public_ip
}

output "worker_node_public_ip" {
  value = aws_instance.worker_node.public_ip
}
