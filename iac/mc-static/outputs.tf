output "Auto_Shutoff_Topic" {
  value = "${aws_sns_topic.mc_shutoff.arn}"
}

output "Minecraft_Public_IP" {
  value = "${aws_eip.mc_ip.public_ip}"
}