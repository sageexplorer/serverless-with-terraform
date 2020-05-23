variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}


data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "greet_lambda.py"
  output_path = "lambda_function.zip"
}

provider "aws" {
  region = "${var.region}"
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
      "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}

EOF
}


resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_logging.arn}"
}


resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function.zip"
  function_name = "greet_lambda"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "greet_lambda.lambda_handler"

  source_code_hash = "${filebase64sha256("lambda_function.zip")}"

  runtime = "python3.7"
  depends_on = ["aws_iam_role_policy_attachment.lambda_logs", "aws_cloudwatch_log_group.example"]

  environment {
    variables = {
      foo = "bar"
    }
  }
}
resource "aws_cloudwatch_log_group" "example" {
  name              = "greet_lambda"
  retention_in_days = 14
}


