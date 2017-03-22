region = "eu-west-1"

web_instance_type = "t2.micro"

name = "webapp"

environment = "dev"

asg_desired_capacity = 2
asg_min_size = 1
asg_max_size = 5
