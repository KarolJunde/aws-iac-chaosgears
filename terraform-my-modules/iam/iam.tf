#--------------------------------------------------------------
# Module to create an AWS IAM group and its users with policies
#--------------------------------------------------------------

variable "name"   { }
variable "users"  { }
variable "inline_group_policy" { }
#variable "inline_user_policy" { }
#variable "user_managed_arn" { }
variable "arn" { }


#--------------------------------------------------------------
# IAM GROUP CREATION
#--------------------------------------------------------------
resource "aws_iam_group" "group" {
  name = "${var.name}"
}

#--------------------------------------------------------------
# IAM USERS CREATION
#--------------------------------------------------------------

resource "aws_iam_user" "user" {
  count = "${length(split(",", var.users))}"
  name  = "${element(split(",", var.users), count.index)}"
}

#--------------------------------------------------------------
# INLINE GROUP POLICY ATTACHEMENT
#--------------------------------------------------------------
resource "aws_iam_group_policy" "policy" {
  name   = "${var.name}"
  group  = "${aws_iam_group.group.id}"
  policy = "${var.inline_group_policy}"
}

resource "aws_iam_access_key" "key" {
  count = "${length(split(",", var.users))}"
  user  = "${element(aws_iam_user.user.*.name, count.index)}"
}

#--------------------------------------------------------------
# INLINE POLICY FOR USER ATTACHEMENT
# Inline policies – Policies that you create and manage, and that are embedded directly into a single user, group, or role.
#--------------------------------------------------------------
#resource "aws_iam_user_policy" "user" {
#  name = "${var.name}"
#  user  = "${var.username}"
#  policy = "${var.inline_user_policy}"
#}

#--------------------------------------------------------------
# MANAGED POLICY FOR USER ATTACHEMENT
# Managed policies – Standalone policies that you can attach to multiple users, groups, and roles in your AWS account. 
# Managed policies apply only to identities (users, groups, and roles) - not resources
#--------------------------------------------------------------

#resource "aws_iam_user_policy_attachment" "managed_user_policy" {
#    count      = "${length(split(",", var.user_managed_arn))}"
#    user       = "${var.username}"
#    policy_arn = "${element(split(",", var.user_managed_arn), count.index)}"
#}

#--------------------------------------------------------------
# MANAGED POLICY FOR GROUP ATTACHEMENT
#--------------------------------------------------------------

resource "aws_iam_group_policy_attachment" "managed_group_policy" {
  count      = "${length(split(",", var.arn))}"
  group      = "${aws_iam_group.group.name}"
  policy_arn = "${element(split(",", var.arn), count.index)}"
}

#--------------------------------------------------------------
# ATTACH USERS TO CREATED GROUP
#--------------------------------------------------------------

resource "aws_iam_group_membership" "attach_users" {
  name  = "${var.name}"
  group = "${aws_iam_group.group.name}"
  users = ["${aws_iam_user.user.*.name}"]
}

output "users"       { value = "${join(",", aws_iam_access_key.key.*.user)}" }
output "access_ids"  { value = "${join(",", aws_iam_access_key.key.*.id)}" }
output "secret_keys" { value = "${join(",", aws_iam_access_key.key.*.secret)}" }