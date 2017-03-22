#----------------------------------------------------------------
# GENERAL VARIABLES
#----------------------------------------------------------------
variable "region" {
  description = "My default region"
}

variable "access_key" {
  description = "My AWS_ACCESS_KEY_ID"
}

variable "secret_key" {
  description = "My AWS_SECRET_ACCESS_KEY"
}

variable "environment" {
}

variable "name" {

}

#----------------------------------------------------------------
# AMI
#----------------------------------------------------------------

variable "web_instance_type" {
  description = "My default instance-type"
}

variable "ami_user_data" {
  description = "My USER_DATA bootstrap file"
  default = "ami_user_data.sh"
}

#----------------------------------------------------------------
# ASG
#----------------------------------------------------------------
variable "asg_desired_capacity" {
  description = "ASG desired capacity"
}

variable "asg_min_size" {
  description = "ASG min numbers of EC2 instances"
}

variable "asg_max_size" {
  description = "ASG max numbers of EC2 instances"
}
