locals {
  # prefix for global uniqueness
  prefix = "${var.aws-profile}"

  # lambda definitions
  lambda_on_shutoff_package = "mc-destroy.zip"
  lambda_on_shutoff_handler = "mc-destroy.handler"
  lambda_on_shutoff_source  = "../../src/mc-destroy.py"

  common_tags = {
    # See https://github.com/hashicorp/terraform/issues/139#issuecomment-250137504
    Name = "minecraft"
  }
}
