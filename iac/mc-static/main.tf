locals {

  lambda_on_shutoff_package = "mc-destroy.zip"
  lambda_on_shutoff_handler = "mc-destroy.handler"
  lambda_on_shutoff_source  = "../../src/mc-destroy.py"

  common_tags = {
    # See https://github.com/hashicorp/terraform/issues/139#issuecomment-250137504
    Name = "minecraft"
  }
}

# Reference to TF state bucket for destroy
data "aws_s3_bucket" "tf_bucket" {
  bucket = "${var.tf-bucket}"
}

# Reference to MC backup bucket for TF config template
data "aws_s3_bucket" "mc_bucket" {
  bucket = "${var.mc-bucket}"
}
