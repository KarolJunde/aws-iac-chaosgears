
#--------------------------------------------------------------
# VPC MODULE 
#--------------------------------------------------------------

variable "name" { default = "vpc" }
variable "region" {default = "eu-central-1"}
variable "cidr" { }

resource "aws_vpc" "vpc" {
  #assign CIDR block i.e 10.0.0.0/16
  cidr_block           = "${var.cidr}"
  # default true
  enable_dns_support   = true
  # default false
  enable_dns_hostnames = true

  tags      { Name = "VPC_${var.name}_${var.region}" }
  lifecycle { create_before_destroy = true }
}

#Create output with vpc_id used in private/public subnets as variables
output "vpc_id"   { value = "${aws_vpc.vpc.id}" }
output "vpc_cidr" { value = "${aws_vpc.vpc.cidr_block}" }