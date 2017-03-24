#--------------------------------------------------------------
# PRIVATE SUBNET MODULE CREATION
#--------------------------------------------------------------

variable "name"            { default = "private_sub"}
variable "region"          { default = "eu-central-1" }
variable "vpc_id"          { }
variable "cidrs"           { }
variable "azs"             { }
variable "nat_gateway_ids" { }

#--------------------------------------------------------------
resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.cidrs))}"

  tags      { Name = "${var.name}_${var.region}_${element(split(",", var.azs), count.index)}" }
  lifecycle { create_before_destroy = true }
}

#--------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"
  count  = "${length(split(",", var.cidrs))}"

# set 0.0.0.0/0 via NAT GATEWAY
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
  }

  tags      { Name = "${var.name}__${var.region}_${element(split(",", var.azs), count.index)}" }
  lifecycle { create_before_destroy = true }
}

#--------------------------------------------------------------
resource "aws_route_table_association" "private" {
  count          = "${length(split(",", var.cidrs))}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"

  lifecycle { create_before_destroy = true }
}
#--------------------------------------------------------------
#create output via list with subnet_ids based on private ids
output "subnet_ids" { value = "${join(",", aws_subnet.private.*.id)}" }