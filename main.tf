provider "aws" {
  region = "eu-central-1"
}
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

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags                 = {
    "Name" = "custom"
  }
}

locals {
  private = ["10.0.1.0/24", "10.0.2.0/24"]
  public  = ["10.0.3.0/24", "10.0.4.0/24"]
  zone    = ["eu-central-1a", "eu-central-1b"]
}

resource "aws_subnet" "private_subnet" {
  count = length(local.private)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.zone[count.index % length(local.zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(local.public)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.zone[count.index % length(local.zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "custom"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each       = {for k, v in aws_subnet.public_subnet : k => v}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "public" {
  subnet_id = aws_subnet.public_subnet[0].id

  depends_on    = [aws_internet_gateway.internet_gateway]
  allocation_id = aws_eip.nat.id

  tags = {
    Name = "Public NAT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table_association" "public_private" {
  route_table_id = aws_route_table.private.id

  for_each  = {for k, v in aws_subnet.private_subnet : k => v}
  subnet_id = each.value.id
}
