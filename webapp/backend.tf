#--------------------------------------------------------------
# S3 WITH DynamoDB LOCKING CONFIGURATION
#--------------------------------------------------------------
terraform {
    backend "s3" {
        bucket 		= "s3-terraform-project"
        key 		= "terraform.tfstate"
        encrypt		= true
        lock_table 	= "DEV_STATE_LOCK"
        region 		= "eu-west-1"


    #  acl		= "bucket-owner-full-control"
    }
}