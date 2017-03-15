# ---------------------------------------------------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# ---------------------------------------------------------------------------------------------------------------------

# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY

#--------------------------------------------------------------------------------------------------------------------

variable "region" {
  description = "My default region"
  default = "eu-central-1"
}

variable "access_key" {
  description = "My AWS_ACCESS_KEY_ID"
  default = ""
}

variable "secret_key" {
  description = "My AWS_SECRET_ACCESS_KEY"
  default = ""
}

variable "instance_type" {
  description = "My default instance-type"
  default = "t2.micro"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 80
}