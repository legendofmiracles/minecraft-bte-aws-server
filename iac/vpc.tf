resource "aws_vpc" "minecraft" {
  cidr_block         = "10.0.0.0/16"
  enable_dns_support = true
  tags               = local.common_tags
}

resource "aws_subnet" "minecraft" {
  vpc_id                  = aws_vpc.minecraft.id
  availability_zone       = var.aws-zones[var.aws-region]
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags                    = local.common_tags
}

resource "aws_internet_gateway" "minecraft" {
  vpc_id = aws_vpc.minecraft.id
  tags   = local.common_tags
}

resource "aws_route_table" "minecraft" {
  vpc_id = aws_vpc.minecraft.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.minecraft.id
  }
}

resource "aws_route_table_association" "minecraft" {
  subnet_id      = aws_subnet.minecraft.id
  route_table_id = aws_route_table.minecraft.id
}
