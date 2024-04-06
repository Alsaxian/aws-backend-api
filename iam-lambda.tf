resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_dynamodb_access" {
  name        = "lambda_dynamodb_access"
  path        = "/"
  description = "IAM policy for accessing DynamoDB from Lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
        ]
        Resource = "${aws_dynamodb_table.car_table.arn}"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_dynamodb_access.arn
}




# # CloudWatch Logs Policy
# resource "aws_iam_policy" "cloudwatch_logs_policy" {
#   name        = "cloudwatch_logs_policy"
#   description = "A policy that allows writing logs to CloudWatch."

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#         ],
#         Resource = "arn:aws:logs:*:*:*",
#         Effect   = "Allow",
#       },
#     ]
#   })
# }

# # Attach AWS Managed Basic Execution Role to the Lambda Role using custom policy
# resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
# }

# Attach AWS Managed Basic Execution Role to the Lambda Role using AWS managed policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# # Outputs
# output "lambda_role_arn" {
#   value = aws_iam_role.lambda_execution_role.arn
# }