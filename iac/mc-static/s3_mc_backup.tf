resource "aws_s3_bucket" "mc_backup" {
  bucket = "${local.prefix}-mc-backup"
  region = "${var.aws-region}"
  acl    = "private"
  
  tags = "${local.common_tags}"
}
