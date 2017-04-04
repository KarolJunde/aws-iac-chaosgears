
variable "allowedips" {}
variable "azs" {}


resource "aws_network_acl_rule" "allow_ssh_to_app_subnets" {
  count = "${length(split(",", var.azs))}"
  network_acl_id = "${aws_network_acl.acl.id}"
  cidr_block = "${element(split(",",var.allowedips), count.index)}"
  rule_action = "allow"
  protocol = "6"
  from_port = "22"
  to_port = "22"
  rule_number = "${count.index + 100}"
}

#--------------------------------------------------------------------------------------
output "rulenumber" {
    value = "${aws_network_acl_rule.allow_ssh_to_app_subnets.ami}"
}

#--------------------------------------------------------------------------------------
output "id" {
    value = "${aws_network_acl_rule.allow_ssh_to_app_subnets.instance_type}"
}
