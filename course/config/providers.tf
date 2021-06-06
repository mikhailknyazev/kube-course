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
    external = {
      source = "hashicorp/external"
      version = "2.1.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.1.2"
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
  config_path    = "~/.kube/config"
  config_context = local.config_context
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = local.config_context
  }
}
