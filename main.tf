terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

# resource "aws_instance" "vpn" {
#   ami           = "ami-0f844a9675b22ea32"
#   instance_type = "t3a.nano"
#   key_name = "vpn"
#   security_groups = ["vpn"]
#   iam_instance_profile  = "vpn"
#   monitoring = true

#   tags = {
#     Name = "vpn"
#   }
# }

resource "aws_instance" "vpn1" {
  ami           = "ami-0f844a9675b22ea32"
  instance_type = "t3a.nano"
  key_name = "vpn"
  security_groups = ["vpn"]
  iam_instance_profile  = "vpn"
  monitoring = true

  tags = {
    Name = "vpn1"
  }
}