output "mongodb_private_ip" {
  value = aws_instance.mongodb.private_ip
}

output "master_public_ip" {
  value = aws_instance.master.public_ip
}