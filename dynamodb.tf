resource "aws_dynamodb_table" "car_table" {
  name         = "CarTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "carId"

  attribute {
    name = "carId"
    type = "S"
  }
}
