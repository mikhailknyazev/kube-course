terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.53.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.4.1"
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
    helm = {
      source = "hashicorp/helm"
      version = "2.2.0"
    }
  }
  required_version = ">= 1.0.4"
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
