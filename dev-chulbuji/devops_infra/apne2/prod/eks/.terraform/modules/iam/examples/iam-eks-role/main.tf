provider "aws" {
  region = "eu-west-1"
}

module "iam_eks_role" {
  source    = "../../modules/iam-eks-role"
  role_name = "my-app"

  cluster_service_accounts = {
    (random_pet.this.id) = ["default:my-app"]
  }

  tags = {
    Name = "eks-role"
  }

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
}

##################
# Extra resources
##################

resource "random_pet" "this" {
  length = 2
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = random_pet.this.id
  cluster_version = "1.21"

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.all.ids
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}
