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

module "eks_cluster" {
  source             = "./modules/eks-cluster"
  cluster_name       = "cluster-ftc2"
  cluster_role_arn   = "arn:aws:iam::160341253529:role/LabRole"
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

module "storage" {
  source                       = "./modules/storage"
  storage_class_name           = "mysql-storageclass"
  provisioner                  = "kubernetes.io/aws-ebs"
  reclaim_policy               = "Delete"
  allow_volume_expansion       = true
  volume_binding_mode          = "WaitForFirstConsumer"
  type                         = "gp2"
  fs_type                      = "ext4"
  encrypted                    = "true"
  persistent_volume_name       = "mysql-data"
  persistent_volume_claim_name = "mysql-data"
  namespace                    = "mysql-data"
  app_label                    = "mysql"
  storage_capacity             = "512Mi"
  access_modes                 = ["ReadWriteOnce"]
  volume_mode                  = "Filesystem"
  host_path                    = "/mnt/mysql-data"
}

module "mysql_deployment" {
  source         = "./modules/mysql"
  name           = "mysql"
  namespace      = "mysql-data"
  labels_app     = "mysql"
  replicas       = 1
  container_name = "mysql-db"
  image          = "mysql:latest"
  container_port = 3306
  env_vars = {
    "MYSQL_DATABASE" = {
      name  = "MYSQL_DATABASE"
      value = "db"
    },
    "MYSQL_PASSWORD" = {
      name  = "MYSQL_PASSWORD"
      value = "admin"
    },
    "MYSQL_ROOT_PASSWORD" = {
      name  = "MYSQL_ROOT_PASSWORD"
      value = "root"
    },
    "MYSQL_USER" = {
      name  = "MYSQL_USER"
      value = "admin"
    }
  }
  volume_name                  = "mysql-data"
  persistent_volume_claim_name = "mysql-data"
  mount_path                   = "/var/lib/mysql"
  restart_policy               = "Always"
  strategy_type                = "Recreate"
}

module "java_app_deployment" {
  source         = "./modules/java-app"
  name           = "java-app"
  namespace      = "java-app"
  labels_app     = "java-app"
  replicas       = 1
  container_name = "java-app"
  image          = "filipeborba/fast-food-app:v7"
  container_port = 8080
  env_vars = {
    "SPRING_DATASOURCE_PASSWORD" = {
      name  = "SPRING_DATASOURCE_PASSWORD"
      value = "admin"
    },
    "SPRING_DATASOURCE_URL" = {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:mysql://mysql.mysql-data.svc.cluster.local:3306/db"
    },
    "SPRING_DATASOURCE_USERNAME" = {
      name  = "SPRING_DATASOURCE_USERNAME"
      value = "admin"
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
  image          = "filipeborba/fast-food-app:v7"
  container_port = 8080
  env_vars = {
    "SPRING_DATASOURCE_PASSWORD" = {
      name  = "SPRING_DATASOURCE_PASSWORD"
      value = "admin"
    },
    "SPRING_DATASOURCE_URL" = {
      name  = "SPRING_DATASOURCE_URL"
      value = "jdbc:mysql://mysql.mysql-data.svc.cluster.local:3306/db"
    },
    "SPRING_DATASOURCE_USERNAME" = {
      name  = "SPRING_DATASOURCE_USERNAME"
      value = "admin"
    }
  }
  resource_limits_cpu      = "1"
  resource_limits_memory   = "1Gi"
  resource_requests_cpu    = "500m"
  resource_requests_memory = "256Mi"
}
