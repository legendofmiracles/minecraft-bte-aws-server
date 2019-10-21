output "Minecraft_Public_IP" {
  value = "${aws_eip_association.minecraft.public_ip}"
}