provider "aws" {
  region = "eu-central-1"
}

resource "aws_instance" "hello" {
  ami           = "ami-0c9354388bb36c088"
  instance_type = "t2.micro"
  tags          = {
    Name = "HelloWorld"
  }
}