#--------------------------------------------------------------
# BASTION HOST MODULE CREATION
#--------------------------------------------------------------

variable "name"              { default = "bastion" }
variable "vpc_id"            { }
variable "vpc_cidr"          { }
variable "region"            { }
variable "public_subnet_ids" { }
variable "key_name"          { }
variable "instance_type"     { }

#--------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"

  tags      { Name = "${var.name}_${var.region}" }
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
# modules/ami directory with main.tf
  source        = "modules/ami"
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
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion.id}"]
  user_data                   = "${template_file.user_data.rendered}"
  associate_public_ip_address = true

  tags      { Name = "${var.name}_${var.region}_${element(split(",", var.subent_ids), count.index)}" }
  lifecycle { create_before_destroy = true }
}

#Create output containing private/public IP od BASTION HOST
output "private_ip" { value = "${aws_instance.bastion.private_ip}" }
output "public_ip"  { value = "${aws_instance.bastion.public_ip}" }