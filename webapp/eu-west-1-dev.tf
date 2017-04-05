variable "name"            { }
variable "env"             { }
variable "region_name"     { }
variable "vpc_cidr"        { }
variable "azs"             { }
variable "private_subnets" { }
variable "public_subnets"  { }
variable "access_key"      { }
variable "secret_key"      { }
variable "bastion_instance_type" { }
variable "version"         { }

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region_name}"
}

module "network" {
  source = "./modules/aws/network"

  name            = "${var.name}"
  env             = "${var.env}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${var.azs}"
  region          = "${var.region_name}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"
  version         = "${var.version}"

  bastion_instance_type = "${var.bastion_instance_type}"
}





