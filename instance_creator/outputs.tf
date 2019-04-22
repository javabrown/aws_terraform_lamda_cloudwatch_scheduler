output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}


output "elastic ip" {
  value = "${aws_eip.default.public_ip}"
}

output "port" {
  value = "${var.server_port}"
}