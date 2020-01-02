terraform {
  backend "s3" {
    profile        = "hlgr360"
    bucket         = "hlgr360-tf-state"
    key            = "mc-static.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}

provider "aws" {
  profile = var.aws-profile
  region  = var.aws-region
}

provider "archive" {
  version = "~> 1.0"
}
