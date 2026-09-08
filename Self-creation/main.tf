provider "aws" {
  region = "us-east-2"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

resource "aws_vpc" "ak_vpc" {
    cidr_block =  var.cidr
}

resource "aws_subnet" "ak_sub1" {
  vpc_id = aws_vpc.ak_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "ak_igw" {
  vpc_id = aws_vpc.ak_vpc.id
}

resource "aws_route_table" "ak_RT" {
  vpc_id = aws_vpc.ak_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ak_igw.id
  }
}

resource "aws_route_table_association" "ak_rta1" {
  subnet_id = aws_subnet.ak_sub1.id
  route_table_id = aws_route_table.ak_RT.id
}

resource "aws_security_group" "ak_sg" {
    name = "ak"
    vpc_id = aws_vpc.ak_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ak-sg"
  }
}

# resource "aws_key_pair" "example" {
#   key_name = "terraform-key-ak"
#   public_key = file("~/.ssh/id_rsa.pub")
# }

resource "tls_private_key" "tls_key_gen_test" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "ak_ec2_key_pair" {
    key_name = "ec2-access-key"
    public_key = tls_private_key.tls_key_gen_test.public_key_openssh
}

resource "local_file" "pem_file_creation" {
    filename = "ec2_tf_test.pem"
    content = tls_private_key.tls_key_gen_test.private_key_pem
    file_permission = 0400
}

resource "aws_instance" "server" {
    ami = "ami-088b41ffb0933423f"
    instance_type = "t3.micro"
    key_name = aws_key_pair.ak_ec2_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.ak_sg.id]
    subnet_id = aws_subnet.ak_sub1.id
    tags = {
        Name = "ec2-akash_test"
        Description = "This instance was created using Terraform for Testing Terraform files"
    }

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = tls_private_key.tls_key_gen_test.private_key_pem
      host = self.public_ip
    }

    provisioner "file" {
      source = "app.py"
      destination = "/home/ec2-user/app.py"
    }

    provisioner "remote-exec" {
      inline = [ 
        "echo 'Hello from the remote instance'",
        "sudo yum update -y",  # Update package lists (for amazopn linux)
        "sudo yum install -y python3-pip",  # Example package installation
        "cd /home/ec2-user",
        "sudo pip3 install flask",
        "sudo python3 app.py",
       ]
    }
}

output "public_ip_address" {
  value = aws_instance.server.public_ip
}