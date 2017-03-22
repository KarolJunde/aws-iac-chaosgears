#--------------------------------------------------------------------------------------
variable "region" {
}
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
resource "aws_instance" "amiweb" {
    instance_type = "${var.instance_type}"
# basing on variables choose the proper ami
    ami = "${lookup(var.ami_image_id, var.region)}"
# basing on variables choose the proper key for EC2
    key_name = "${lookup(var.key_name, var.region)}"
}

#--------------------------------------------------------------------------------------
# reference to aws_instance.amiweb -> variable ami
output "id" {
    value = "${aws_instance.amiweb.ami}"
}

#--------------------------------------------------------------------------------------
# reference to aws_instance.amiweb -> variable instance_type
output "instance_type" {
    value = "${aws_instance.amiweb.instance_type}"
}

#--------------------------------------------------------------------------------------
# reference to aws_instance.amiweb -> variable key_name
output "key" {
    value = "${aws_instance.amiweb.key_name}"
}