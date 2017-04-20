variable "name"              { }
variable "region"            { }
variable "users_dev"     	 { }
variable "access_key"     	 { }
variable "secret_key"      	 { }
variable "arn" 				 { }

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

module "user_group_dev" {
 source = "git::https://gitlab.com/KarolJunde/AWStemplate.git//terraform-my-modules/iam"
 #source = "../../terraform-my-modules/iam/"

  name       = "${var.name}_GROUP_DEV"
  users      = "${var.users_dev}"
  arn 		 = "${var.arn}"

  inline_group_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "aws-portal:*Billing",
                "aws-portal:*Usage",
                "aws-portal:*PaymentMethods",
                "budgets:ViewBudget",
                "budgets:ModifyBudget"
            ],
            "Resource": "*"
        }
    ]
}
EOF

#inline_user_policy = <<EOF EOF

#managed_user_policy = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"

}


output "IAM_USERS_DATA" {
  value = <<CONFIG

CREATED IAM USERS WITH FOLLOWING ACCESS/SECRET KEYS:

  Users:    ${join(" ", formatlist("%s", split(",", module.user_group_dev.users)))}

  Access IDs:  ${join("\n             ", formatlist("%s", split(",", module.user_group_dev.access_ids)))}
  
  Secret Keys: ${join("\n              ", formatlist("%s", split(",", module.user_group_dev.secret_keys)))}

CONFIG
}

#output "iam_users"       { value = "${module.user_group_dev.users}" }
#output "iam_access_ids"  { value = "${module.user_group_dev.access_ids}" }
#output "iam_secret_keys" { value = "${module.user_group_dev.secret_keys}" }