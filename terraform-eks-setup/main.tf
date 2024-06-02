resource "aws_vpc" "tf-kube-vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "tf-kube-vpc"
  }
}

resource "aws_subnet" "tf-subnet1" {
  vpc_id                  = aws_vpc.tf-kube-vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet1"
  }
}

resource "aws_subnet" "tf-subnet2" {
  vpc_id                  = aws_vpc.tf-kube-vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-subnet2"
  }
}

resource "aws_internet_gateway" "tf-igw1" {
  vpc_id = aws_vpc.tf-kube-vpc.id

  tags = {
    Name = "tf-igw1"
  }

}

resource "aws_route_table" "tf-rt1" {
  vpc_id = aws_vpc.tf-kube-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw1.id
  }

  tags = {
    Name = "tf-rt1"
  }

}

resource "aws_route_table_association" "tf-rta1" {
  route_table_id = aws_route_table.tf-rt1.id
  subnet_id      = aws_subnet.tf-subnet1.id

}

resource "aws_route_table_association" "tf-rta2" {
  route_table_id = aws_route_table.tf-rt1.id
  subnet_id      = aws_subnet.tf-subnet2.id

}

resource "aws_security_group" "tf-sg1" {
  name        = "EKS-SG"
  vpc_id      = aws_vpc.tf-kube-vpc.id
  description = "Security Group for EKS worker nodes"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "ALL"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_role" "tf-eks-cluster-role" {
  name = "tf-eks-cluster-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy-attatch-cluster" {
  role       = aws_iam_role.tf-eks-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

resource "aws_iam_role" "tf-eks-node-group-role" {
  name = "tf-eks-node-group-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17"
    "Statement" : [
      {
        "Effect" : "Allow"
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy-attatch-node-cni" {
  role       = aws_iam_role.tf-eks-node-group-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}

resource "aws_iam_role_policy_attachment" "policy-attatch-node-worker" {
  role       = aws_iam_role.tf-eks-node-group-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

resource "aws_iam_role_policy_attachment" "policy-attatch-node-container" {
  role       = aws_iam_role.tf-eks-node-group-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}


resource "aws_eks_cluster" "atlas-eks" {
  name     = "atlas-eks"
  role_arn = aws_iam_role.tf-eks-cluster-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.tf-subnet1.id,
      aws_subnet.tf-subnet2.id
    ]
    security_group_ids = [
      aws_security_group.tf-sg1.id
    ]
    endpoint_public_access = true
  }

  depends_on = [
    aws_vpc.tf-kube-vpc,
    aws_subnet.tf-subnet1,
    aws_subnet.tf-subnet2,
    aws_security_group.tf-sg1,
    aws_iam_role_policy_attachment.policy-attatch-cluster
  ]
}

resource "aws_eks_node_group" "tf-eks-node-group" {
  cluster_name    = aws_eks_cluster.atlas-eks.name
  node_group_name = "tf-eks-node-group"
  node_role_arn   = aws_iam_role.tf-eks-node-group-role.arn
  ami_type        = "AL2_x86_64"
  instance_types = [
    "t2.micro"
  ]
  subnet_ids = [
    aws_subnet.tf-subnet1.id,
    aws_subnet.tf-subnet2.id
  ]
  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 3
  }

  depends_on = [
    aws_iam_role_policy_attachment.policy-attatch-node-cni,
    aws_iam_role_policy_attachment.policy-attatch-node-container,
    aws_iam_role_policy_attachment.policy-attatch-node-worker
  ]
}