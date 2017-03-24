#!/bin/bash
    yum update -y
    yum install git stress -y
    yum install python-pip -y
    pip install --upgrade --user awscli
#    service httpd start
#    cd /var/www/html
#    wget https://s3.eu-central-1.amazonaws.com/s3-terraform-shared/index.php
#    echo "healthy!!!" > healthy.html
#    chkconfig httpd on
