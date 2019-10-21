locals {
  common_tags = {
    # See https://github.com/hashicorp/terraform/issues/139#issuecomment-250137504
    Name = "minecraft"
  }
}

# ------------------------------------
# IAM Roile for mincraft world backup on S3
# ------------------------------------
resource "aws_iam_instance_profile" "minecraft" {
  name = "mc-backup"
  role = "${aws_iam_role.minecraft.name}"
}

resource "aws_iam_role" "minecraft" {
  name = "mc-backup-role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

  tags = local.common_tags
}

resource "aws_iam_role_policy" "minecraft" {
  name = "mc-backup-policy"
  role = "${aws_iam_role.minecraft.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# ------------------------------------
# Minecraft server
# ------------------------------------
resource "aws_instance" "minecraft" {
  # free tier eligible
  instance_type = "t2.micro"

  ami               = var.ami-images[var.aws-region]
  security_groups   = [aws_security_group.minecraft.id]
  availability_zone = var.aws-zones[var.aws-region]
  key_name          = var.ec2-key-pair-name
  depends_on        = [aws_internet_gateway.minecraft]
  subnet_id         = aws_subnet.minecraft.id

  iam_instance_profile = aws_iam_instance_profile.minecraft.name

  root_block_device {
    volume_type = "standard"
    volume_size = 40
  }

  tags        = local.common_tags
  volume_tags = local.common_tags
}

resource "aws_eip_association" "minecraft" {
  instance_id   = aws_instance.minecraft.id
  allocation_id = var.eip-id
}

# -----------------------------------------
# Provision the minecraft server using remote-exec
# -----------------------------------------
resource "null_resource" "minecraft" {
  triggers = {
    public_ip = aws_eip_association.minecraft.public_ip
  }

  connection {
    type        = "ssh"
    host        = aws_eip_association.minecraft.public_ip
    user        = "ec2-user"
    port        = "22"
    private_key = file("~/.ssh/${var.ec2-key-pair-name}.pem")
  }

  // copy pre-configured ec2 instance private key
  provisioner "file" {
    source      = "~/.ssh/${var.ec2-key-pair-name}.pem"
    destination = "id_rsa"
  }

  // copy auto-shutoff function
  provisioner "file" {
    source      = "../files/auto_shutoff.py"
    destination = "auto_shutoff.py"
  }

  // copy deployment and start script
  provisioner "file" {
    source      = "../files/mc-setup.sh"
    destination = "mc-setup.sh"
  }
  provisioner "file" {
    source      = "../files/mc-server.sh"
    destination = "mc-server.sh"
  }

  // install minecraft and sync backup
  provisioner "remote-exec" {
    inline = [
      "chmod a+x minecraft-*.sh",
      "./mc-setup.sh ${var.mc-bucket}",
      "./mc-server.sh start",
    ]
  }
}

