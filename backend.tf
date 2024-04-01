terraform {
  backend "s3" {
    bucket = "xitry-terraform-state"
    key    = "aws-backend-api/terraform.tfstate"
    region = "us-east-1"
  }
}