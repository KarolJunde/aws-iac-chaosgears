# ---------------------------------------------------------------------------------------------------------------------
# Ubuntu AMI
# ---------------------------------------------------------------------------------------------------------------------
module "ami_image" {
# modules/ami directory with main.tf
  source        = "modules/ami"
# instance_type variable replaced with web_instance_type from "webapp_dev.tfvars"
  instance_type = "${var.web_instance_type}"
# region variable replaced with region from "webapp_dev.tfvars"
  region        = "${var.region}"
}

# GET THE LIST OF AVAILABILITY ZONES IN THE CURRENT REGION
# Every AWS account has slightly different availability zones in each region.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "all" {}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A LAUCH CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "webapp" {
  name            = "LC-${var.environment}_${var.name}"
  image_id        = "${module.ami_image.id}"
  instance_type   = "${var.web_instance_type}"
  security_groups = ["${aws_security_group.webapp.id}"]
  key_name        = "${module.ami_image.key}"
#  iam_instance_profile = "${aws_iam_instance_profile.default.name}"
  user_data       = "${template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "webapp" {
  name   = "SG_EC2_${var.environment}_${var.name}"
 # vpc_id = "${terraform_remote_state.shared.output.vpc_id}"

  # Inbound HTTP from anywhere
  ingress {
    from_port = 80
    to_port = 80
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

#-------------
# USE USER-DATA SCRIPT DURING BOOTSTRAPING
#-------------

resource "template_file" "user_data" {
  template = "${file("${var.ami_user_data}")}"

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A ALG 
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_autoscaling_group" "webapp" {
  name                 = "ASG-${var.name}"
  launch_configuration = "${aws_launch_configuration.webapp.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  desired_capacity          = "${var.asg_desired_capacity}"
  min_size                  = "${var.asg_min_size}"
  max_size                  = "${var.asg_max_size}"

 #  Tell the ASG to register each Instance in the ELB when that instance is booting
   load_balancers = ["${aws_elb.MyELB.name}"]

 # Tells the ASG to use the ELB’s health check to determine if an Instance is healthy or not 
 # and to automatically restart Instances if the ELB reports them as unhealthy
   health_check_type = "ELB"


  tag {

    key = "Name"
    value = "EC2_${var.name}_${var.environment}"
    propagate_at_launch = true

  }

  tag {

    key = "Team"
    value = "Dev"
    propagate_at_launch = true

  }

   tag {

    key = "Region"
    value = "${var.region}"
    propagate_at_launch = true

  }
      lifecycle {
        create_before_destroy = true
    }
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A ELB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_elb" "MyELB" {
  name = "ELB-${var.environment}-${var.name}"
  # Reference to resource "aws_security_group" "elb"
  security_groups = ["${aws_security_group.elb.id}"]
  # from data "aws_availability_zones" "all" {}
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  cross_zone_load_balancing = true

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 10
    target = "HTTP:80/healthy.html"
  }

   listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

 lifecycle {
        create_before_destroy = true
    }
   
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC AN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "elb" {
  name = "SG-ELB_${var.environment}-${var.name}"

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Inbound SSL from anywhere
   ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }


      lifecycle {
        create_before_destroy = true
    }
}



