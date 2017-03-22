output "configuration" {
  value = <<CONFIGURATION
Web application has been deployed in ${var.environment} environment

Url:            ${aws_elb.MyELB.dns_name}

CONFIGURATION
}