#--------------------------------------------------------------
# GENERAL
#--------------------------------------------------------------

name              = "MyWebApp1.0"
env               = "Staging"
team			  = "Devs"
region_name       = "eu-west-1"
#version		  = "v0.0.1"

#--------------------------------------------------------------
# NETWORK CREATION
#--------------------------------------------------------------

vpc_cidr        = "10.50.0.0/16"
azs             = "eu-west-1a,eu-west-1b,eu-west-1c" 		    # AZs are region specific
private_subnets = "10.50.1.0/24,10.50.2.0/24,10.50.3.0/24" 		# Creating one private subnet per AZ
public_subnets  = "10.50.11.0/24,10.50.12.0/24,10.50.13.0/24" 	# Creating one public subnet per AZ

# Bastion
bastion_instance_type = "t2.micro"

#--------------------------------------------------------------
# S3 BUCKET CREATION
#--------------------------------------------------------------

versioning       = true
bucketname       = "s3terraformfiles"
acl       		 = "private"

#--------------------------------------------------------------
# WEB APP ASG/ELB CREATION
#--------------------------------------------------------------

instancetype = "t2.micro"
appname = "WebApp"
asg_desired_capacity = 2
asg_min_size = 1
asg_max_size = 5