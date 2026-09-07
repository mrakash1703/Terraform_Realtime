terraform {
  backend "s3" {
    bucket = "akash-s3-demo-xyz"
    region = "us-east-1"
    key = "akash/terraform.tfstate"
# Dynamo DB copnfig added after creating DynamoDB\
    dynamodb_table = "terraform_lock"
  }
}