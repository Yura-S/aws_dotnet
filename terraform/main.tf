##############################################getting data of existing resources that is uses later

data "aws_availability_zones" "working" {}

data "aws_ami" "latest_ubuntu" {

  owners      = ["099720109477"]
  most_recent = true

  filter {
  name        = "name"
  values      = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  count = length(data.aws_subnets.default.ids)
  id    = data.aws_subnets.default.ids[count.index]
}

data "aws_route53_zone" "existing_zone" {
  name = "ysahakyan.devopsaca.site"
}

############################################creating security group of cluster

resource "aws_security_group" "web" {

  name          = "web sg"
  vpc_id        = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each    = ["80", "443", "22"]
    content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  }
}

############################################creating cluster

resource "aws_eks_cluster" "my_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.my_cluster_role.arn

  vpc_config {
    subnet_ids         = [data.aws_subnets.default.ids[0],data.aws_subnets.default.ids[1]]
    security_group_ids = [aws_security_group.web.id]
  }
}

############################################creating cluster role

resource "aws_iam_role" "my_cluster_role" {
  name = "my-eks-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

############################################attaching policies to cluster role

resource "aws_iam_role_policy_attachment" "my_cluster_role_policy1" {
  role       = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "my_cluster_role_policy2" {
  role       = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "my_cluster_role_policy3" {
  role       = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "my_cluster_role_policy4" {
  role       = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

############################################creating node group and nodes

resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.nodes_role.arn
  subnet_ids      = [data.aws_subnets.default.ids[0],data.aws_subnets.default.ids[1]] 

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
}

############################################creating role for node group

resource "aws_iam_role" "nodes_role" {
  name = "node_group_role"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

############################################attaching policies to node group role

resource "aws_iam_role_policy_attachment" "node" {
  role       = aws_iam_role.nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node1" {
  role       = aws_iam_role.nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node2" {
  role       = aws_iam_role.nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

############################################creating postgre database

resource "aws_db_instance" "education" {
  identifier            = "postgrestestdb"
  db_name          = "PostgresTestDb"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14"
  username               = "postgres"
  password               = "12453265"
  #db_subnet_group_name   = aws_db_subnet_group.education.name
  #vpc_security_group_ids = ["sg-00159ecab0efad675"]
  #parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  vpc_security_group_ids = [aws_security_group.postgres_db.id,]
}

############################################get database for terraform

data "aws_db_instance" "education" {
  db_instance_identifier = aws_db_instance.education.id
}

############################################get security group created automatically when created node group

data "aws_security_group" "node_group_sg" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = ["my-eks-cluster"]
  }

  depends_on = [aws_eks_node_group.my_node_group]
}

############################################creating security group for database

resource "aws_security_group" "postgres_db" {
  name        = "postgres-db-sg"
  description = "Security group for PostgreSQL RDS"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [data.aws_security_group.node_group_sg.id]
  }
}
