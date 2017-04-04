#--------------------------------------------------------------
# General
#--------------------------------------------------------------

name              = "MyWebApp"
env               = "production"
region_name       = "eu-west-1"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

vpc_cidr        = "10.10.0.0/16"
azs             = "eu-west-1a,eu-west-1b,eu-west-1c" 		    # AZs are region specific
private_subnets = "10.10.1.0/24,10.10.2.0/24,10.10.3.0/24" 		# Creating one private subnet per AZ
public_subnets  = "10.10.11.0/24,10.10.12.0/24,10.10.13.0/24" 	# Creating one public subnet per AZ

# Bastion
bastion_instance_type = "t2.micro"

#--------------------------------------------------------------