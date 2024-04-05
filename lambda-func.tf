resource "aws_lambda_function" "api_handler" {
  function_name    = "api_handler"
  handler          = "index.handler" # Adjust based on your programming language and handler name
  runtime          = "nodejs14.x"    # Or your runtime of choice
  filename         = var.func_output_path
  source_code_hash = filebase64sha256(var.func_output_path)

  role = aws_iam_role.lambda_exec.arn
}

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

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = var.func_source_dir
  output_path = var.func_output_path
}