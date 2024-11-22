resource "aws_instance" "master_node" {
  ami           = var.ubuntu_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = file("userdata/master-userdata.sh")

  tags = {
    Name = "k8s-master-node"
  }
}

resource "aws_instance" "worker_node" {
  ami           = var.ubuntu_ami
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = file("userdata/worker-userdata.sh")

  tags = {
    Name = "k8s-worker-node"
  }
}

output "master_ip" {
  value = aws_instance.master_node.public_ip
}

output "worker_ip" {
  value = aws_instance.worker_node.public_ip
}
