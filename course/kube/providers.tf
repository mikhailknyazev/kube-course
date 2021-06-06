terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.40.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.1.0"
    }
    null = {
      source = "hashicorp/null"
      version = "~> 3.1.0"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.1.0"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
  required_version = ">= 0.15"
}

provider "aws" {
  default_tags {
    tags = {
      owner = "kube-course"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
