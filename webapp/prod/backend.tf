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
    	access_key	= "AKIAJMNQUH3KXUAMIBLA"
		secret_key	= "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"

    #  acl		= "bucket-owner-full-control"
    }
}