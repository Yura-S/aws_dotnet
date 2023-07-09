##############################################

data "aws_availability_zones" "working" {}

data "aws_ami" "latest_ubuntu" {

  owners      = ["099720109477"]
  most_recent = true

  filter {
  name        = "name"
  values      = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

#data "aws_ami" "SiteImage" {
#  most_recent = true
#
#  owners = ["self"]
#  tags = {
#    Name   = "WebSiteImage"
#  }
#}

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

############################################

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

############################################

resource "aws_acm_certificate" "ycert" {
  private_key      = file("${path.module}/privkey.pem")
  certificate_body = file("${path.module}/cert.pem")
  certificate_chain = file("${path.module}/chain.pem")
}

resource "aws_acm_certificate" "yapicert" {
  private_key      = file("${path.module}/privkey1.pem")
  certificate_body = file("${path.module}/cert1.pem")
  certificate_chain = file("${path.module}/chain1.pem")
}

############################################

#resource "aws_route53_record" "lb_record" {
#  zone_id = data.aws_route53_zone.existing_zone.zone_id
#  name    = "api.ysahakyan.devopsaca.site"
#  type    = "A"
#
#
#  #es sranic araj el er comment @st erevuytin avel er chei jnjel
#  #records = [aws_lb.web.dns_name]
#
#  alias {
#    name                   = aws_lb.web.dns_name
#    zone_id                = aws_lb.web.zone_id
#    evaluate_target_health = true
#  }
#}

############################################

# Define the EKS cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-eks-cluster"  # Replace with your desired cluster name
  role_arn = aws_iam_role.my_cluster_role.arn  # Replace with the ARN of your IAM role

  vpc_config {
    subnet_ids         = [data.aws_subnets.default.ids[0],data.aws_subnets.default.ids[1]]  # Replace with your subnet IDs
    security_group_ids = [aws_security_group.web.id]  # Replace with your security group IDs
  }
}

# Define the IAM role for the EKS cluster
resource "aws_iam_role" "my_cluster_role" {
  name = "my-eks-cluster-role"  # Replace with your desired role name

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

# Attach the necessary IAM policies to the role
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

############################################

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
  # Role configuration options...
}

resource "aws_iam_role_policy_attachment" "node" {
  role       = aws_iam_role.nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  # Attach other policies as needed...
}

resource "aws_iam_role_policy_attachment" "node1" {
  role       = aws_iam_role.nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  # Attach other policies as needed...
}

resource "aws_iam_role_policy_attachment" "node2" {
  role       = aws_iam_role.nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  # Attach other policies as needed...
}

############################################

#data "aws_eks_cluster" "my_cluster" {
#  name = "my-eks-cluster"  # Replace with the name of your EKS cluster
#  depends_on = [data.aws_eks_cluster.my_cluster]
#}
############################################################################################################################################

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
  #vpc_security_group_ids = [aws_security_group.rds.id]
  #vpc_security_group_ids = ["sg-00159ecab0efad675"]
  #parameter_group_name   = aws_db_parameter_group.education.name
  publicly_accessible    = false
  skip_final_snapshot    = true
  
  vpc_security_group_ids = [
    aws_security_group.postgres_db.id,
  ]
}

data "aws_db_instance" "education" {
  db_instance_identifier = aws_db_instance.education.id
}



resource "aws_security_group" "postgres_db" {
  name        = "postgres-db-sg"
  description = "Security group for PostgreSQL RDS"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    #petqa dnel en sg-n vor@ noderic outbound-a anum depi esi
    security_groups = [data.aws_security_group.node_group_sg.id]
  }
}

data "aws_security_group" "node_group_sg" {
  filter {
    name   = "tag:aws:eks:cluster-name"
    values = ["my-eks-cluster"]
  }

  depends_on = [aws_eks_node_group.my_node_group]
}

############################################

resource "aws_route53_record" "example" {
  zone_id = "Z057290428AHLJHX3Z6WE"  # Replace with the actual zone ID of your hosted zone
  name    = "ysahakyan.devopsaca.site"
  type    = "A"

  alias {
    name                   = "s3-website-us-east-1.amazonaws.com."
    zone_id                = "Z3AQBSTGFYJSTF"  # Replace with the S3 zone ID for the desired region
    evaluate_target_health = true
  }
}


##############################################################################################################################################

#output "ep" {
#value = local.rds_endpoint
#}
