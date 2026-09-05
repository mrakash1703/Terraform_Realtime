provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example" {
    ami =  "ami-<ID>"
    instance_type = "t2.micro"
    subnet_id = "subnet-<ID>"
    key_name = "<Key_name>"
}