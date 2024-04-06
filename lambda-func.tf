resource "aws_lambda_function" "api_handler" {
  function_name    = "cars-func"
  handler          = "cars.carsHandler" 
  runtime          = "python3.12" 
  filename         = var.func_output_path
  source_code_hash = filebase64sha256(var.func_output_path)

  role = aws_iam_role.lambda_exec.arn
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = var.func_source_dir
  output_path = var.func_output_path
}