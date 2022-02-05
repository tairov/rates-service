terraform {
  backend "s3" {
    bucket         = "rates-service-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "rates-service-terraform-state-table"
  }
}
