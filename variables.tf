variable "func_source_dir" {
  description = "The path to the directory containing the Lambda function code"
  default     = "func/"
}

variable "func_output_path" {
  description = "The path to the output zip file"
  default     = "target/lambda.zip"
}

