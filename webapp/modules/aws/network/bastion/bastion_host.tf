#--------------------------------------------------------------
# BASTION HOST MODULE CREATION v1.0
#--------------------------------------------------------------

variable "name"              { }
variable "env"               { }
variable "vpc_id"            { }
variable "vpc_cidr"          { }
variable "region"            { }
variable "public_subnet_ids" { }
variable "instance_type"     { }

variable "ami_user_data" {
  description = "My USER_DATA bootstrap file"
  default = "ami_user_data.sh"
}

#--------------------------------------------------------------
resource "aws_security_group" "bastion" {
  
  name        = "${var.name}_${var.env}"
  vpc_id      = "${var.vpc_id}"

  tags      { Name = "SG-${var.name}" }
  tags      { Env = "${var.env}" }
  tags      { Region = "${var.region}" }


  lifecycle { create_before_destroy = true }

 # ingress {
  #  protocol    = -1
  #  from_port   = 0
  #  to_port     = 0
  #  cidr_blocks = ["${var.vpc_cidr}"]
  #}

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#--------------------------------------------------------------
module "ami" {
# /ami directory with createami.tf
  source        = "./ami"
# instance_type variable replaced with web_instance_type from "webapp_dev.tfvars"
  instance_type = "${var.instance_type}"
# region variable replaced with region from "webapp_dev.tfvars"
  region        = "${var.region}"
}

#--------------------------------------------------------------
# USE USER-DATA SCRIPT DURING BOOTSTRAPING
#--------------------------------------------------------------

resource "template_file" "user_data" {
  template = "${file("${var.ami_user_data}")}"

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami                         = "${module.ami.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name                    = "${module.ami.key}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  user_data                   = "${template_file.user_data.rendered}"
  associate_public_ip_address = true


  tags      { Name = "BASTION-${var.name}-${element(split(",", var.public_subnet_ids), count.index)}" }
  tags      { Region = "${var.region}" }
  tags      { Env = "${var.env}" }

  lifecycle { create_before_destroy = true }
}

#Create output containing private/public IP od BASTION HOST
output "private_ip" { value = "${aws_instance.bastion.private_ip}" }
output "public_ip"  { value = "${aws_instance.bastion.public_ip}" }
