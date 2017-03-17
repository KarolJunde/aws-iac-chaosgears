#syntax (TYPE.NAME.*.ATTRIBUTE) because aws_instance.example is now a list 
#of EC2 Instances and not a single EC2 Instance
#output "public_ip" {
 # value = "${aws_launch_configuration.example.*.public_ip}"
#}
output "elb_dns_name" {
  value = "${aws_elb.MyELB.dns_name}"
}