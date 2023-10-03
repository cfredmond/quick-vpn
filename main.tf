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
#   key_name = ""
#   security_groups = [""]
#   iam_instance_profile  = ""
#   monitoring = true

#   tags = {
#     Name = ""
#   }
# }

# resource "aws_instance" "vpn2" {
#   ami           = "ami-0f844a9675b22ea32"
#   instance_type = "t3a.nano"
#   key_name = "vpn"
#   security_groups = ["vpn"]
#   iam_instance_profile  = "vpn"
#   monitoring = true
#   user_data = <<EOF
# #!/bin/bash 
# aws s3 cp s3://quick-vpn/quick-vpn.zip .
# unzip quick-vpn.zip
# ./quick-vpn/setup.sh
# EOF

#   tags = {
#     Name = "vpn2"
#   }
# }