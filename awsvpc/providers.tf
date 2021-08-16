terraform {
  required_provider {
      aws = {
          source = "hashicorp/aws"
          version = "~> 3.0"
      }
  }
}

provider "aws" {
    region = var.nvpc_region
  
}