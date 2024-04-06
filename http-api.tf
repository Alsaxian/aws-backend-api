# Define the HTTP API
resource "aws_apigatewayv2_api" "http_api" {
  name          = "cars-api"
  protocol_type = "HTTP"
  description   = "API for car operations"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.api_handler.invoke_arn
}

locals {
  api_methods = [
    "GET /health",
    "GET /cars",
    "GET /car",
    "POST /car",
    "DELETE /car",
    "PATCH /car"
  ]
  api_route_target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "api_routes" {
  for_each = toset(local.api_methods)

  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = each.value
  target    = local.api_route_target
}

# # Enable CORS if required
# resource "aws_apigatewayv2_cors_configuration" "cors" {
#   api_id = aws_apigatewayv2_api.http_api.id

#   allow_headers = ["Content-Type"]
#   allow_methods = ["GET", "POST", "PATCH", "DELETE"]
#   allow_origins = ["*"]
# }

# Define the 'dev' stage
resource "aws_apigatewayv2_stage" "dev" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}