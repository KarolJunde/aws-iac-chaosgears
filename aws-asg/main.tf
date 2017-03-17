# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
    access_key = "${var.access_key}"
  	secret_key = "${var.secret_key}"
  	region     = "${var.region}"
}

# GET THE LIST OF AVAILABILITY ZONES IN THE CURRENT REGION
# Every AWS accout has slightly different availability zones in each region.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "all" {}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A LAUCH CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "example" {
  image_id = "ami-af0fc0c0"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name = "MyEC2KeyPair"
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd php git stress -y
              service httpd start
              cd /var/www/html
              wget https://s3.eu-central-1.amazonaws.com/terraformgit/index.php
              echo healthy!!! > healthy.html
              chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name = "terraform-EC2-sg"

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A ALG 
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "example" {
  name                 = "terraform-asg"
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  min_size = 1
  max_size = 4
  desired_capacity = 2

 #  Tell the ASG to register each Instance in the ELB when that instance is booting
   load_balancers = ["${aws_elb.MyELB.name}"]

 # Tells the ASG to use the ELB’s health check to determine if an Instance is healthy or not 
 # and to automatically restart Instances if the ELB reports them as unhealthy
   health_check_type = "ELB"


  tag {

    key = "Name"
    value = "EC2_ASG_${var.region}"
    propagate_at_launch = true

  }

  tag {

    key = "Team"
    value = "Dev"
    propagate_at_launch = true

  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A ELB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_elb" "MyELB" {
  name = "terraform-elb"
  # Reference to resource "aws_security_group" "elb"
  security_groups = ["${aws_security_group.elb.id}"]
  # from data "aws_availability_zones" "all" {}
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 10
    target = "HTTP:${var.server_port}/healthy.html"
  }

   listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.server_port}"
    instance_protocol = "http"
  }

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC AN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "elb" {
  name = "terraform-elb-sg"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound SSH from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


