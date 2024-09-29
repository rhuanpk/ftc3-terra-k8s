terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster_info.endpoint
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_info.certificate_authority[0].data)
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = ["us-east-1a", "us-east-1b"][count.index]
  map_public_ip_on_launch = true
}

# Obter o ARN da role do cluster EKS usando um data source
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

module "eks_cluster" {
  source             = "./modules/eks-cluster"
  cluster_name       = "cluster-ftc3"
  cluster_role_arn   = data.aws_iam_role.lab_role.arn
  # cluster_role_arn   = "arn:aws:iam::438392353047:role/LabRole"
  subnet_ids         = aws_subnet.public_subnets.*.id
  kubernetes_version = "1.24"
}

module "eks_cluster_nodes" {
  source        = "./modules/nodes"
  cluster_name  = module.eks_cluster.cluster_name
  node_role_arn = module.eks_cluster.cluster_role_arn_iam
  subnet_ids    = aws_subnet.public_subnets.*.id
}

data "aws_eks_cluster" "cluster_info" {
  depends_on = [module.eks_cluster]
  name       = module.eks_cluster.cluster_name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  depends_on = [module.eks_cluster]
  name       = module.eks_cluster.cluster_name
}

module "namespace" {
  source = "./modules/namespaces"
}

module "java_app_deployment" {
  source         = "./modules/java-app"
  name           = "java-app"
  namespace      = "java-app"
  labels_app     = "java-app"
  replicas       = 1
  container_name = "java-app"
  image          = "brunocampossousa/ftc3-app:latest"
  container_port = 8080
  env_vars = {
    "SPRING_DATASOURCE_PASSWORD" = {
      name  = "SPRING_DATASOURCE_PASSWORD"
      value = "admin123"
    },
    "SPRING_DATASOURCE_URL" = {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:mysql://mysql-ftc3.cnsgp0m1uiux.us-east-1.rds.amazonaws.com:3306/db"
    },
    "SPRING_DATASOURCE_USERNAME" = {
      name  = "SPRING_DATASOURCE_USERNAME"
      value = "admin"
    },
    "AUTH_URL" = {
      name  = "AUTH_URL"
      value = "https://jw1v21uqkj.execute-api.us-east-1.amazonaws.com/v1/autenticar-python"
    }
  }
  resource_limits_cpu      = "1"
  resource_limits_memory   = "1Gi"
  resource_requests_cpu    = "500m"
  resource_requests_memory = "256Mi"
  restart_policy           = "Always"
}

module "autoscaling" {
  source              = "./modules/autoscaling"
  name                = "java-app-hpa"
  namespace           = "java-app"
  target_kind         = "Deployment"
  target_name         = "java-app"
  api_version         = "apps/v1"
  min_replicas        = 2
  max_replicas        = 5
  metric_type         = "Resource"
  resource_name       = "cpu"
  target_type         = "Utilization"
  average_utilization = 50
}

module "pod_disruption_budget" {
  source        = "./modules/pdb"
  name          = "java-app-pdb"
  namespace     = "java-app"
  min_available = "1"
  match_labels = {
    app = "java-app"
  }
}

module "java_app_replicaset" {
  source         = "./modules/replicaset"
  namespace      = "java-app"
  replicas       = 2
  image          = "brunocampossousa/ftc3-app:latest"
  container_port = 8080
  env_vars = {
    "SPRING_DATASOURCE_PASSWORD" = {
      name  = "SPRING_DATASOURCE_PASSWORD"
      value = "admin"
    },
    "SPRING_DATASOURCE_URL" = {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:mysql://mysql-ftc3.cnsgp0m1uiux.us-east-1.rds.amazonaws.com:3306/db"
    },
    "SPRING_DATASOURCE_USERNAME" = {
      name  = "SPRING_DATASOURCE_USERNAME"
      value = "admin"
    },
    "AUTH_URL" = {
      name  = "AUTH_URL"
      value = "https://jw1v21uqkj.execute-api.us-east-1.amazonaws.com/v1/autenticar-python"
    }
  }
  resource_limits_cpu      = "1"
  resource_limits_memory   = "1Gi"
  resource_requests_cpu    = "500m"
  resource_requests_memory = "256Mi"
}
