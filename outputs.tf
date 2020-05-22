
# Define the output variable for the lambda function.


output "role" {
  description = "The Amazon Resource Name (ARN) identifying your Lambda Function."
  value       =  "${aws_lambda_function.test_lambda.role}"
}

output "function_name" {
  description = "The name of the role for the Lambda Function."
  value       =  "${aws_lambda_function.test_lambda.function_name}"
}
