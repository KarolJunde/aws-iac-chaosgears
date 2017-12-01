#!/bin/bash

aws ec2 create-volume --size 10 --region eu-west-1 --availability-zone eu-west-1c --volume-type gp2