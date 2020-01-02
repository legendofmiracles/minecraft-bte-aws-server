resource "aws_sns_topic" "mc_shutoff" {
  name = "mc-shutoff"
  tags = local.common_tags
}
