variable "name"              { }
variable "region"            { }
variable "iam_testers"       { }
variable "access_key"     	 { }
variable "secret_key"      	 { }

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
}

module "iam_testers" {
  source = "git::https://gitlab.com/KarolJunde/AWStemplate.git//terraform-my-modules/iam"

  name       = "${var.name}-tester"
  users      = "${var.iam_testers}"
  policy     = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF

 user_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

output "IAM_USERS_DATA" {
  value = <<CONFIG

CREATED IAM USERS WITH FOLLOWING ACCESS/SECRET KEYS:

  Users: ${join("\n               ", formatlist("%s", split(",", module.iam_testers.users)))}
  Access IDs: ${join("\n              ", formatlist("%s", split(",", module.iam_testers.access_ids)))}
  Secret Keys: ${join("\n               ", formatlist("%s", split(",", module.iam_testers.secret_keys)))}

CONFIG
}

output "iam_users"       { value = "${module.iam_testers.users}" }
output "iam_access_ids"  { value = "${module.iam_testers.access_ids}" }
output "iam_secret_keys" { value = "${module.iam_testers.secret_keys}" }