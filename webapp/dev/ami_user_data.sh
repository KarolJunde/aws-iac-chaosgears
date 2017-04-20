#!/bin/bash
    yum update -y
    yum install git stress -y
    yum install python-pip -y
    yum install python-dev -y
    pip install --upgrade --user awscli
#    service httpd start
#    cd /var/www/html
#    wget https://s3-eu-west-1.amazonaws.com/s3-terraform-project/index.php
#    echo "healthy!!!" > healthy.html
#    chkconfig httpd on
