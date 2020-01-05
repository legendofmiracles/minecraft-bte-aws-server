resource "aws_eip" "mc_ip" {
    tags = "${local.common_tags}"
}