variable "name"              { }
variable "region"            { }
variable "iam_testers"       { }

provider "aws" {
  region = "${var.region}"
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
            "Action": [
                "iam:ChangePassword"
            ],
            "Resource": [
                "arn:aws:iam::*:user/${aws:username}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:GetAccountPasswordPolicy"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

output "config" {
  value = <<CONFIG

CREATED IAM:
  Admin Users: ${join("\n               ", formatlist("%s", split(",", module.iam_testers.users)))}
  Access IDs: ${join("\n              ", formatlist("%s", split(",", module.iam_testers.access_ids)))}
  Secret Keys: ${join("\n               ", formatlist("%s", split(",", module.iam_testers.secret_keys)))}

CONFIG
}

output "iam_users"       { value = "${module.iam_admin.users}" }
output "iam_access_ids"  { value = "${module.iam_admin.access_ids}" }
output "iam_secret_keys" { value = "${module.iam_admin.secret_keys}" }