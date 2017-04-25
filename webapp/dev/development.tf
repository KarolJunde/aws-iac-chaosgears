#--------------------------------------------------------------
# DEPLOY ENVIRONMENT FOR APP
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
provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region_name}"
}
#--------------------------------------------------------------

#--------------------------------------------------------------
module "s3amicreation" {
  source = "git::https://gitlab.com/KarolJunde/AWStemplate.git//terraform-my-modules/s3"
  #source = "../../terraform-my-modules/s3/"

  bucketname      = "${var.bucketname}"
  env             = "${var.env}"
  team            = "${var.team}"
  versioning      = "${var.versioning}"
  acl             = "${var.acl}"
}

output "s3URL" {
  value = "${module.s3amicreation.s3URL}"
}

output "s3hostingURL" {
  value = "${module.s3amicreation.s3hostingURL}"
}

