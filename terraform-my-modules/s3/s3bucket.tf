#--------------------------------------------------------------
# Module to create an S3 bucket
#--------------------------------------------------------------

variable "bucketname"       { }
variable "env"              { }
variable "team"             { }
variable "versioning"       { }
variable "acl"              { default = "private"}

#--------------------------------------------------------------
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucketname}"
  acl    = "${var.acl}"

  versioning {
    enabled = "${var.versioning}"
  }

  tags {

    BucketName        = "${var.bucketname}"
    Env               = "${var.env}"
    Team              = "${var.team}"
    CreationDate      = "${timestamp()}"
  }
}
#--------------------------------------------------------------
output "s3URL" {
  value = "http://s3-${aws_s3_bucket.bucket.region}.amazonaws.com/${aws_s3_bucket.bucket.bucket}"
}

output "s3hostingURL" {
  value = "${aws_s3_bucket.bucket.bucket}.s3-website-${aws_s3_bucket.bucket.region}.amazonaws.com"
}
#--------------------------------------------------------------