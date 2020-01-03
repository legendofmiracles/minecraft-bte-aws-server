locals {
  common_tags = {
    # See https://github.com/hashicorp/terraform/issues/139#issuecomment-250137504
    Name = "minecraft"
  }
}

# reference static SNS queue for auto-shutoff
data "aws_sns_topic" "mc_shutoff" {
  name = "mc-shutoff"
}