// Define AWS provider and Terraform requirements
terraform {
  required_version = ">= 1.5.0"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.app_name
      ManagedBy = "Terraform"
    }
  }

  # Credenciais são lidas das variáveis de ambiente:
  # AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY (ou perfil configurado via AWS CLI).
}
