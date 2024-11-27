provider "aws" {
  region = "eu-west-1"
}

# VPC
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.default.id
}

# Route Table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.default.id
}

# Route for Internet Access
resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.route_table.id
}

# Subnet (Public)
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-1"
  }
}

# Security Groups for Kubernetes Nodes
resource "aws_security_group" "k8s_sg" {
  name_prefix = "k8s-sg"
  vpc_id      = aws_vpc.default.id
  description = "Kubernetes master and worker nodes security group"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# MongoDB Security Group
resource "aws_security_group" "mongodb_sg" {
  name_prefix = "mongodb-sg"
  vpc_id      = aws_vpc.default.id
  description = "MongoDB EC2 instance security group"

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [
      aws_security_group.k8s_sg.id
    ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance (Master Node)
resource "aws_instance" "master" {
  ami                    = "ami-0d64bb532e0502c46"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.subnet_1.id
  key_name               = var.key_name  # Burada PEM anahtarınızın adı olacak
  vpc_security_group_ids = [
    aws_security_group.k8s_sg.id,
    aws_security_group.mongodb_sg.id
  ]
  user_data              = file("master.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2_connect_role.name

  tags = {
    Name = "k8s-master"
  }
}

# EC2 Instance (Worker Node)
resource "aws_instance" "worker" {
  ami                    = "ami-0d64bb532e0502c46"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.subnet_1.id
  key_name               = var.key_name  # Burada PEM anahtarınızın adı olacak
  vpc_security_group_ids = [
    aws_security_group.k8s_sg.id,
    aws_security_group.mongodb_sg.id
  ]
  user_data              = file("worker.sh")
  iam_instance_profile   = aws_iam_instance_profile.ec2_connect_role.name

  tags = {
    Name = "k8s-worker"
  }
}

# EC2 Instance (MongoDB Node)
resource "aws_instance" "mongodb" {
  ami                    = "ami-0d64bb532e0502c46"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.subnet_1.id
  key_name               = var.key_name  # Burada PEM anahtarınızın adı olacak
  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]

  tags = {
    Name = "mongodb-node"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2_connect_role.name
}

# IAM Role & Policy
resource "aws_iam_role" "ec2_connect_role" {
  name = "ec2connect-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ec2connect_policy" {
  name        = "ec2connect-policy"
  description = "EC2 Connect Policy"
  policy      = file("ec2connect-policy.json")
}

resource "aws_iam_policy" "worker_node_policy" {
  name        = "worker-node-policy"
  description = "Worker Node Policy"
  policy      = file("worker-node-policy.json")
}

resource "aws_iam_instance_profile" "ec2_connect_role" {
  role = aws_iam_role.ec2_connect_role.name
}

resource "aws_iam_role_policy_attachment" "ec2connect_policy_attachment" {
  policy_arn = aws_iam_policy.ec2connect_policy.arn
  role       = aws_iam_role.ec2_connect_role.name
}

resource "aws_iam_role_policy_attachment" "worker_node_policy_attachment" {
  policy_arn = aws_iam_policy.worker_node_policy.arn
  role       = aws_iam_role.ec2_connect_role.name
}

resource "aws_iam_role_policy_attachment" "full_access_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.ec2_connect_role.name
}
