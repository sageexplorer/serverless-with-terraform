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

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function.zip"
  function_name = "greet_lambda"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "greet_lambda.lambda_handler"

  source_code_hash = "${filebase64sha256("lambda_function.zip")}"

  runtime = "python3.7"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
