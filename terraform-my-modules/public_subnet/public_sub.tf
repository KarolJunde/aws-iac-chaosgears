#--------------------------------------------------------------
# PUBLIC SUBNET MODULE CREATION
#--------------------------------------------------------------

variable "name"   { }
variable "env"    { }
variable "region" { }
variable "vpc_id" { }
variable "cidrs"  { }
variable "azs"  { }

#--------------------------------------------------------------
resource "aws_internet_gateway" "public" {
  vpc_id = "${var.vpc_id}"

  tags      { Name = "IGW-${var.name}-${var.env}" }
  tags      { Region = "${var.region}" }
  tags      { Env = "${var.env}" }
}
#--------------------------------------------------------------
resource "aws_subnet" "public" {

  #name              = "PubSub-${var.name}-${var.env}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.cidrs), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.cidrs))}"

  tags      { Name = "PubSub-${var.name}-${var.env}-${element(split(",", var.azs), count.index)}" }
  tags      { Env = "${var.env}" }
  tags      { Region = "${var.region}" }

  lifecycle { create_before_destroy = true }

# Specify true to indicate that instances launched into the subnet should be assigned a public IP address 
  map_public_ip_on_launch = true
}
#--------------------------------------------------------------
resource "aws_route_table" "public" {
  
  #name   = "PubTable-${var.name}-${var.env}"
  vpc_id = "${var.vpc_id}"

# set 0.0.0.0/0 via IGW
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags      { Name = "PubTable-${var.name}-${var.env}-${element(split(",", var.azs), count.index)}" }
  tags      { Env = "${var.env}" }
  tags      { Region = "${var.region}" }
}
#--------------------------------------------------------------
resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.cidrs))}"
#associate created public subnets with route table public
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

#create output with subnet_ids based on public ids used in nat_gateway
output "subnet_ids" { value = "${join(",", aws_subnet.public.*.id)}" }
