provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "akash" {
    instance_type = "t2-micro"
    ami = "ami-<id>"
    subnet_id = "subnet-<id>"
}