variable "env" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "nodes_keypair" {
  default = ""
}
variable "vpc_id" {
  default = ""
}
resource "aws_iam_role" "iam_role_01" {
  name = "iam-role-01-${var.env}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "role_01_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_role_01.name
}

# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "role_01_eks_pods_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.iam_role_01.name
}


resource "aws_security_group" "sg_eks_cluster" {
  name   = "security-group-eks-cluster-${var.env}"
  vpc_id = var.vpc_id

  # Egress allows Outbound traffic from the EKS cluster to the  Internet

  egress { # Outbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Ingress allows Inbound traffic to EKS cluster from the  Internet

  ingress { # Inbound Rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_eks_cluster" "eks_01" {
  name     = "eks-${var.env}"
  role_arn = aws_iam_role.iam_role_01.arn
  version  = "1.19"

  vpc_config {
    security_group_ids      = [aws_security_group.sg_eks_cluster.id]
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.role_01_eks_cluster_policy,
    aws_iam_role_policy_attachment.role_01_eks_pods_resource_controller,
  ]
  tags = {
    Name = "eks-01-cluster-${var.env}"
  }
}


resource "aws_iam_role_policy_attachment" "role_01_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.iam_role_01.name
}

resource "aws_iam_role_policy_attachment" "role_01_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.iam_role_01.name
}

resource "aws_iam_role_policy_attachment" "role_01_eks_ec2_container_registry_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.iam_role_01.name
}


resource "aws_eks_node_group" "eks_01_node_group_01" {
  cluster_name    = aws_eks_cluster.eks_01.name
  node_group_name = "eks_01_node_group_${var.env}"
  node_role_arn   = aws_iam_role.iam_role_01.arn
  subnet_ids = [
  var.subnet_ids[0]]

  instance_types = ["t3.small", "t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = var.nodes_keypair
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.role_01_eks_ec2_container_registry_readonly,
    aws_iam_role_policy_attachment.role_01_eks_cni_policy,
    aws_iam_role_policy_attachment.role_01_eks_worker_node_policy
  ]
}

output "endpoint" {
  value = aws_eks_cluster.eks_01.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_01.certificate_authority[0].data
}
