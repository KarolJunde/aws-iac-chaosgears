# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
    access_key = "${var.access_key}"
  	secret_key = "${var.secret_key}"
  	region     = "${var.region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "EC2example" {
  # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type in eu-central-1
  ami = "ami-af0fc0c0"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name = "MyEC2KeyPair"
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
			  yum install httpd php git stress -y
    		  service httpd start
    		  cd /var/www/html
              wget https://s3.eu-central-1.amazonaws.com/terraformgit/index.php
			  chkconfig httpd on
              EOF

  tags {
    Name = "myEC2example"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name = "terraform-EC2-example"

lifecycle {
    create_before_destroy = true
  }

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

   # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


