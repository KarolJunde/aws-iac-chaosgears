#--------------------------------------------------------------
# PRIVATE SUBNET MODULE CREATION
#--------------------------------------------------------------

variable "name"            { }
variable "env"             { }
variable "region"          { default = "eu-central-1" }
variable "vpc_id"          { }
variable "cidrs"           { }
variable "azs"             { }
variable "nat_gateway_ids" { }

#--------------------------------------------------------------
resource "aws_subnet" "private" {
  #name              = "PrivSub-${var.name}-${var.env}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.cidrs))}"

  tags      { Name = "PrivSub-${var.name}-${var.env}-${element(split(",", var.azs), count.index)}" }
  tags      { Env  = "${var.env}" }
  tags      { Region = "${var.region}" }

  lifecycle { create_before_destroy = true }
}

#--------------------------------------------------------------
resource "aws_route_table" "private" {
  #name   = "PrivTable-${var.name}-${var.env}"
  vpc_id = "${var.vpc_id}"
  count  = "${length(split(",", var.cidrs))}"

# set 0.0.0.0/0 via NAT GATEWAY
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(split(",", var.nat_gateway_ids), count.index)}"
  }

  tags      { Name = "PrivTable-${var.name}-${var.env}-${element(split(",", var.azs), count.index)}" }
  tags      { Env  = "${var.env}" }
  tags      { Region  = "${var.region}" }

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