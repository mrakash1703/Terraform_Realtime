provider "aws" {
    region = "us-east-1"
}

module "ec2_instance" {
    source = "./modules/ec2_instance"
    ami_value = "ami-<value>"
    instance_type_value = "t2.micro"
    subnet_id_value = "subnet-<value>"
}