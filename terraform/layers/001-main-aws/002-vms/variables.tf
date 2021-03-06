variable "group" {}
variable "env" {}
variable "region" {}
variable "drone_url" {}
variable "hosted_zone_id" {}
variable "vpc_cidr" {}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_type_master" {
  default = "t2.medium"
}

data "aws_ami" "debian" {
  most_recent = true
  filter {
    name   = "name"
    values = ["debian-stretch-hvm-x86_64-gp2*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["379101102735"] # Debian Project
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.group}-${var.env}-${var.region}-tfstate"
    key    = "001-vpc.tfstate"
    region = var.region
  }
}
