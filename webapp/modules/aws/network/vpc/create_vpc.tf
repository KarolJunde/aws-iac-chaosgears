
#--------------------------------------------------------------
# VPC MODULE 
#--------------------------------------------------------------

variable "name" { }
variable "env"  { }
variable "region" { }
variable "cidr" { }

resource "aws_vpc" "vpc" {
  
  #name   			   = "VPC-${var.name}-${var.env}"
  #assign CIDR block i.e 10.0.0.0/16
  cidr_block           = "${var.cidr}"
  # default true
  enable_dns_support   = true
  # default false
  enable_dns_hostnames = true

  tags      { Name = "VPC-${var.name}-${var.env}" }
  tags      { Env = "${var.env}" }
  tags      { Region = "${var.region}" }

  lifecycle { create_before_destroy = true }
}

#Create output with vpc_id used in private/public subnets as variables
output "vpc_id"   { value = "${aws_vpc.vpc.id}" }
output "vpc_cidr" { value = "${aws_vpc.vpc.cidr_block}" }