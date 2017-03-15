output "public_ip" {
  value = "${aws_instance.EC2example.public_ip}"
}