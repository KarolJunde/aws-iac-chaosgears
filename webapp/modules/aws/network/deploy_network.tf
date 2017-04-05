#--------------------------------------------------------------
# DEPLOY VPC WITH BASTION HOST/PRIV/PUBLIC SUBNET
#--------------------------------------------------------------

variable "name"            { }
variable "env"             { }
variable "vpc_cidr"        { }
variable "azs"             { }
variable "region"          { }
variable "private_subnets" { }
variable "public_subnets"  { }
variable "bastion_instance_type" { }
#variable "version"           { }

#--------------------------------------------------------------
# VPC MODULE PART
#--------------------------------------------------------------
module "vpc" {
  source = "./vpc"

  name = "${var.name}"
  region = "${var.region}"
  env  = "${var.env}"
  cidr = "${var.vpc_cidr}"
}

#--------------------------------------------------------------
# BASTION MODULE PART
#--------------------------------------------------------------
module "public_subnet" {
  source = "./public_subnet"

  name   = "${var.name}"
  region = "${var.region}"
  env    = "${var.env}"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.public_subnets}"
  azs    = "${var.azs}"
}

#--------------------------------------------------------------
# BASTION MODULE PART
#--------------------------------------------------------------
module "bastion" {
  source = "./bastion"

  name              = "${var.name}"
  env               = "${var.env}"
  vpc_id            = "${module.vpc.vpc_id}"
  vpc_cidr          = "${module.vpc.vpc_cidr}"
  region            = "${var.region}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
  instance_type     = "${var.bastion_instance_type}"

}

#--------------------------------------------------------------
# NAT GATEWAY MODULE PART
#--------------------------------------------------------------
module "nat" {
  source = "./nat"

  name              = "${var.name}"
  azs               = "${var.azs}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
}

#--------------------------------------------------------------
# PRIVATE SUBNET MODULE PART
#--------------------------------------------------------------
module "private_subnet" {
  source = "./private_subnet"

  name   = "${var.name}"
  env    = "${var.env}"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.private_subnets}"
  azs    = "${var.azs}"

  nat_gateway_ids = "${module.nat.nat_gateway_ids}"
}

#--------------------------------------------------------------
# ACL FOR VPC
#--------------------------------------------------------------

resource "aws_network_acl" "acl" {
  
  #name       = "ACL-${var.name}-${var.env}"
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${concat(split(",", module.public_subnet.subnet_ids), split(",", module.private_subnet.subnet_ids))}"]

  ingress {
    protocol   = "6"
    rule_no    = 500
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "6"  #TCP
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags { Name = "ACL-${var.name}" }
  tags { Region = "${var.region}" }
  tags { Env = "${var.env}" }
}

# VPC
output "vpc_id"   { value = "${module.vpc.vpc_id}" }
output "vpc_cidr" { value = "${module.vpc.vpc_cidr}" }

# Subnets
output "public_subnet_ids"  { value = "${module.public_subnet.subnet_ids}" }
output "private_subnet_ids" { value = "${module.private_subnet.subnet_ids}" }

# Bastion
output "bastion_private_ip" { value = "${module.bastion.private_ip}" }
output "bastion_public_ip"  { value = "${module.bastion.public_ip}" }

# NAT
output "nat_gateway_ids" { value = "${module.nat.nat_gateway_ids}" }

