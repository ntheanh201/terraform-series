#provider "aws" {
#  region = "eu-central-1"
#}
#
#data "aws_ami" "ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#  }
#
#  owners = ["099720109477"] # Canonical Ubuntu AWS account id
#}
#
#resource "aws_instance" "snapify_release" {
#  count         = 2
#  ami           = data.aws_ami.ubuntu.id
#  #  instance_type = "t2.micro"
#  instance_type = var.instance_type
#  tags          = {
#    Name = "HelloWorld"
#  }
#}
#
#output "ec2" {
#  value = {
#  #    1. Use normal way
#  #    public_ip_release_1 = aws_instance.snapify_release[0].public_ip
#  #    public_ip_release_2 = aws_instance.snapify_release[1].public_ip
#  #    2. Use for expressions:
#  #    public_ip = [for v in aws_instance.snapify_release : v.public_ip]
#  #    3. Use format function
#  for i, v in aws_instance.snapify_release : format("public_ip_%d", i+1) => v.public_ip
#  }
#}