// Lambda function to auto shutoff
resource "aws_lambda_function" "on_shutoff" {
  function_name    = "mc-on-shutoff"
  handler          = "${local.lambda_on_shutoff_handler}"
  filename         = "${data.archive_file.on_shutoff.output_path}"
  source_code_hash = "${data.archive_file.on_shutoff.output_base64sha256}"
  runtime          = "python3.6"
  role             = "${aws_iam_role.lambda_on_shutoff.arn}"
  publish          = true
  memory_size      = 256
  timeout          = 300
  tags             = "${local.common_tags}"
}

// Ref: https://github.com/hashicorp/terraform/issues/6513
data "archive_file" "on_shutoff" {
  type        = "zip"
  source_file = "${local.lambda_on_shutoff_source}"
  output_path = "${local.lambda_on_shutoff_package}"
}

// Lambda trigger on SNS event
resource "aws_lambda_permission" "on_shutoff" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.on_shutoff.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.mc_shutoff.arn}"
}

// Lambda subscribe to SNS topic
resource "aws_sns_topic_subscription" "on_shutoff" {
  topic_arn = "${aws_sns_topic.mc_shutoff.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.on_shutoff.arn}"
}

// The IAM role actually used by the lambda functions
resource "aws_iam_role" "lambda_on_shutoff" {
  name               = "lambda-on-shutoff"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_on_shutoff_exec.json}"
}

// The IAM role policy used by the lambda functions
data "aws_iam_policy_document" "lambda_on_shutoff_exec" {
  statement {
    effect  = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

// The discrete role policy, which attaches an IAM policy to the Lambda function
resource "aws_iam_role_policy" "lambda_on_shutoff" {
  name = "on-shutoff-policy"
  role = "${aws_iam_role.lambda_on_shutoff.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "NotAction": [
                "iam:*",
                "organizations:*",
                "account:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:Get*",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:ListInstanceProfilesForRole",
                "iam:DeleteInstanceProfile",
                "iam:CreateServiceLinkedRole",
                "iam:DeleteServiceLinkedRole",
                "iam:ListRoles",
                "organizations:DescribeOrganization",
                "account:ListRegions"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
