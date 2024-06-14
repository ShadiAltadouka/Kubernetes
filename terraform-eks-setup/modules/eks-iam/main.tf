// IAM ROLE FOR CLUSTER
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

// CLUSTER POLICTY ATTATCHMENT
resource "aws_iam_role_policy_attachment" "policy-attatch-cluster" {
  role       = aws_iam_role.tf-eks-cluster-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

// IAM ROLE FOR NODE GROUP
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

// NODE GROUP POLICY ATTATCHMENT
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

resource "aws_iam_policy" "ebs_csi_driver_policy" {
  name        = "AmazonEBSCSIDriverPolicy"
  description = "Policy for EBS CSI Driver"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:AttachVolume",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteSnapshot",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DetachVolume"
        ],
        "Resource" : "*"
      }
    ]
  })
}

// Attach the Policy to the Node Group Role
resource "aws_iam_role_policy_attachment" "tfpolicyattach5" {
  role       = aws_iam_role.tf-eks-node-group-role.name
  policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
}

// EKS CLUSTER
resource "aws_eks_cluster" "atlas-eks" {
  name     = "atlas-eks"
  role_arn = aws_iam_role.tf-eks-cluster-role.arn

  vpc_config {
    subnet_ids = [
      var.subnet-1-id,
      var.subnet-2-id
    ]
    security_group_ids = [
      var.security-group-id
    ]
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.policy-attatch-cluster
  ]
}

// EKS NODE GROUP
resource "aws_eks_node_group" "tf-eks-node-group" {
  cluster_name    = aws_eks_cluster.atlas-eks.name
  node_group_name = "tf-eks-node-group"
  node_role_arn   = aws_iam_role.tf-eks-node-group-role.arn
  ami_type        = "AL2_x86_64"
  instance_types = [
    "t2.medium"
  ]
  subnet_ids = [
    var.subnet-2-id,
    var.subnet-2-id
  ]
  scaling_config {
    desired_size = 3
    min_size     = 1
    max_size     = 3
  }

  launch_template {
    id = var.launch-template-id
    version = var.launch-template-version
  }

  depends_on = [
    aws_iam_role_policy_attachment.policy-attatch-node-cni,
    aws_iam_role_policy_attachment.policy-attatch-node-container,
    aws_iam_role_policy_attachment.policy-attatch-node-worker
  ]
}