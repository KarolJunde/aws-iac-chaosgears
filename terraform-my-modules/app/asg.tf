variable "web_instance_type"    { }
variable "region"               { }
variable "appname"              { }
variable "asg_desired_capacity" { }
variable "asg_min_size"         { }
variable "asg_max_size"         { }
variable "env"                  { }
variable "team"                 { }
variable "azs"                  { }
variable "public_subnets"       { }
variable "vpc_id"               { }

module "ami_image" {
  source        = "modules/ami"
  instance_type = "${var.web_instance_type}"
  region        = "${var.region}"
  env           = "${var.env}"
  team          = "${var.team}"
  appname       = "${var.appname}"
}

# GET THE LIST OF AVAILABILITY ZONES IN THE CURRENT REGION
# Every AWS account has slightly different availability zones in each region.
# ---------------------------------------------------------------------------------------------------------------------

#data "aws_availability_zones" "all" {}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A LAUCH CONFIGURATION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_launch_configuration" "webapp" {
  name            = "LauchConf-${var.env}-${var.appname}"
  image_id        = "${module.ami_image.id}"
  instance_type   = "${var.web_instance_type}"
  security_groups = ["${aws_security_group.webapp.id}"]
  key_name        = "${module.ami_image.key}"
#  iam_instance_profile = "${aws_iam_instance_profile.default.name}"
#  user_data       = "${template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO EACH EC2 INSTANCE IN THE ASG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "webapp" {
  vpc_id      = "${var.vpc_id}"
  name        = "SecGr-EC2-${var.env}-${var.appname}"
 # vpc_id = "${terraform_remote_state.shared.output.vpc_id}"

  # Inbound HTTP from ELB only
  ingress {
    from_port         = 80
    to_port           = 80
    protocol          = "tcp"
    security_groups   = ["${aws_security_group.elb.id}"]
  }

   ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
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
resource "aws_autoscaling_group" "webapp" {
  name                      = "ASG-${var.env}-${var.appname}"
  launch_configuration      = "${aws_launch_configuration.webapp.id}"
  vpc_zone_identifier       = ["${split(",", var.public_subnets)}"]
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
    value = "ASG-${var.appname}-${var.env}"
    propagate_at_launch = true

  }

  tag {

    key = "Team"
    value = "${var.team}"
    propagate_at_launch = true

  }

   tag {

    key = "Region"
    value = "${var.region}"
    propagate_at_launch = true

  }

  tag {

    key = "Env"
    value = "${var.env}"
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
  name                        = "ELB-${var.env}-${var.appname}"
  security_groups             = ["${aws_security_group.elb.id}"]
  # availability_zones        = ["${data.aws_availability_zones.all.names}"]
  subnets                     = ["${split(",", var.public_subnets)}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400

  health_check {
    healthy_threshold       = 2
    unhealthy_threshold     = 2
    timeout                 = 3
    interval                = 10
    target                  = "HTTP:80/healthy.html"
  }

   listener {
    lb_port                 = 80
    lb_protocol             = "http"
    instance_port           = 80
    instance_protocol       = "http"
  }

 lifecycle {
        create_before_destroy = true
    }

    tags {
    Name              = "ELB-${var.appname}-${var.env}"
    env               = "${var.env}"
    Team              = "${var.team}"
    CreationDate      = "${timestamp()}"
  }
   
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP THAT CONTROLS WHAT TRAFFIC AN GO IN AND OUT OF THE ELB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "elb" {
  vpc_id      = "${var.vpc_id}"
  name        = "SG-ELB-${var.env}-${var.appname}"

  # Allow all outbound
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

# Inbound SSL from anywhere
   ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    cidr_blocks     = ["0.0.0.0/0"]
  }


      lifecycle {
        create_before_destroy = true
    }
}


output "ELB" {
  value = "${aws_elb.MyELB.dns_name}"
}
