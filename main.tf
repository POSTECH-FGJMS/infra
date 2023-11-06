/* sync config */

terraform {
  backend "s3" {
    bucket         = "lanchonete-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lanchonete-terraform-state"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

/* RDS */
resource "aws_db_subnet_group" "public_db_subnet_group" {
  name       = "public-db-subnet-group"
  subnet_ids = ["${var.subnet_id1}", "${var.subnet_id2}"]
}

resource "aws_security_group" "public_rds_sg" {
  name        = "public-rds-sg"
  description = "Security group for RDS instance with public access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
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

resource "aws_db_instance" "lanchonete_rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.micro"
  db_name              = "lanchonete"
  identifier           = "lanchonete-rds"
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.public_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.public_rds_sg.id]
}

/* EKS */
resource "aws_eks_cluster" "lanchonete_cluster" {
  name     = "lanchonete-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = [var.subnet_id3, var.subnet_id4]
    security_group_ids = [ var.securtiy_group_id ]
    endpoint_private_access = true
    endpoint_public_access = true
  }
}

resource "aws_iam_role" "eks_cluster" {
  name = "lanchonete-cluster-eks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_node_group" "lanchonete_node_group" {
  cluster_name    = aws_eks_cluster.lanchonete_cluster.name
  node_group_name = "lanchonete-cluster-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = [var.subnet_id3, var.subnet_id4]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}

resource "aws_iam_role" "eks_nodes" {
  name = "lanchonete-cluster-eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}
