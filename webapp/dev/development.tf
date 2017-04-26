#--------------------------------------------------------------
# DEPLOY ENVIRONMENT FOR APP
#--------------------------------------------------------------


#--------------------------------------------------------------
#                VARIABLES
#--------------------------------------------------------------

variable "name"            { }
variable "env"             { }
variable "team"            { }
variable "region_name"     { }
variable "vpc_cidr"        { }
variable "azs"             { }
variable "private_subnets" { }
variable "public_subnets"  { }
variable "access_key"      { }
variable "secret_key"      { }
variable "bastion_instance_type" { }
#variable "version"         { }

#--------------------------------------------------------------

variable "bucketname"      { }
variable "acl"             { }
variable "versioning"      { }

#--------------------------------------------------------------
variable "asg_desired_capacity" {
  description = "ASG desired capacity"
}

variable "asg_min_size" {
  description = "ASG min numbers of EC2 instances"
}

variable "asg_max_size" {
  description = "ASG max numbers of EC2 instances"
}

variable "instancetype" {
}

variable "appname" {}

#--------------------------------------------------------------
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region_name}"
}

#--------------------------------------------------------------
#                 MODULES
#--------------------------------------------------------------
module "network" {
  source = "../../terraform-my-modules/network_deploy/"
 # source = "git::https://gitlab.com/KarolJunde/AWStemplate.git//terraform-my-modules/network_deploy"

  name            = "${var.name}"
  env             = "${var.env}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${var.azs}"
  region          = "${var.region_name}"
  private_subnets = "${var.private_subnets}"
  public_subnets  = "${var.public_subnets}"

  bastion_instance_type = "${var.bastion_instance_type}"
}

#--------------------------------------------------------------
module "s3amistore" {
  source = "git::https://gitlab.com/KarolJunde/AWStemplate.git//terraform-my-modules/s3"
  #source = "../../terraform-my-modules/s3/"

  bucketname      = "${var.bucketname}"
  env             = "${var.env}"
  team            = "${var.team}"
  versioning      = "${var.versioning}"
  acl             = "${var.acl}"
}

#--------------------------------------------------------------
module "appelb" {
  #source = "../../terraform-my-modules/app/"
  source = "git::https://gitlab.com/KarolJunde/AWStemplate.git//terraform-my-modules/app/"

  web_instance_type     = "${var.instancetype}"
  public_subnets        = "${module.network.public_subnet_ids}"
  appname               = "${var.appname}"
  region                = "${var.region_name}"
  asg_desired_capacity  = "${var.asg_desired_capacity}"
  asg_min_size          = "${var.asg_min_size}"
  asg_max_size          = "${var.asg_max_size}"
  env                   = "${var.env}"
  azs                   = "${var.azs}"
  team                  = "${var.team}"
  vpc_id                = "${module.network.vpc_id}"
 
}
#--------------------------------------------------------------
#                 OUTPUTS
#--------------------------------------------------------------

output "s3URL" {
  value = "${module.s3amistore.s3URL}"
}

output "s3hostingURL" {
  value = "${module.s3amistore.s3hostingURL}"
}
#--------------------------------------------------------------

output "ELB" {
  value = "${module.appelb.ELB}"
}

