data "google_secret_manager_secret_version" "aws_access_key" {
  secret  = "aws-access-key"
  project = data.google_project.project.project_id
}

data "google_secret_manager_secret_version" "aws_secret_key" {
  secret  = "aws-secret-key"
  project = data.google_project.project.project_id
}

provider "aws" {
  region     = "us-east-1"
  access_key = data.google_secret_manager_secret_version.aws_access_key.secret_data
  secret_key = data.google_secret_manager_secret_version.aws_secret_key.secret_data
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "example2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Main"
  }
  availability_zone = "us-east-1b"
}

data "aws_iam_role" "cluster" {
  name = "eksClusterRole"
}

resource "aws_eks_cluster" "example" {
  name     = local.cluster_name
  role_arn = data.aws_iam_role.cluster.arn


  vpc_config {
    subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]
  }
}
