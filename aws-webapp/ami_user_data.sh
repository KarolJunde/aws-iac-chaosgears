#!/bin/bash
    yum update -y
    yum install httpd php git stress -y
    service httpd start
    cd /var/www/html
    wget https://s3.eu-central-1.amazonaws.com/s3-terraform-shared/index.php
    echo "healthy!!!" > healthy.html
    chkconfig httpd on
