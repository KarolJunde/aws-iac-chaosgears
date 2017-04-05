#--------------------------------------------------------------
# MANUAL AMI MODULE CREATION
#--------------------------------------------------------------
#--------------------------------------------------------------------------------------
variable "region" {}
variable "name" {}
variable "env" {}

#--------------------------------------------------------------------------------------
variable "ami_image_id" {
  description = "My default AMI ID based on REGION"
   type = "map"

  default = {
    eu-central-1 = "ami-af0fc0c0"
    eu-west-1    = "ami-70edb016"
  }
}

#--------------------------------------------------------------------------------------
variable "instance_type" {
    default ="t2.micro"
}

#--------------------------------------------------------------------------------------
variable "key_name" {
  type = "map"

  default = {
    eu-central-1 = "MyEC2KeyPair"
    eu-west-1    = "MyIrelandKeyPair"
  }
}

#--------------------------------------------------------------------------------------
resource "aws_instance" "instance" {
    instance_type = "${var.instance_type}"
# basing on variables choose the proper ami
    ami = "${lookup(var.ami_image_id, var.region)}"
# basing on variables choose the proper key for EC2
    key_name = "${lookup(var.key_name, var.region)}"

 # tags      { Name = "AMI-${var.name}" }
 # tags      { Env = "${var.env}" }
 # tags      { Region = "${var.region}" }
  
  }

#--------------------------------------------------------------------------------------
# reference to aws_instance.instance -> variable ami
output "id" {
    value = "${aws_instance.instance.ami}"
}

#--------------------------------------------------------------------------------------
# reference to aws_instance.instance -> variable instance_type
output "instance_type" {
    value = "${aws_instance.instance.instance_type}"
}

#--------------------------------------------------------------------------------------
# reference to aws_instance.instance -> variable key_name
output "key" {
    value = "${aws_instance.instance.key_name}"
}