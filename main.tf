terraform {
  resource "aws_instance" "test" {
  ami           = "00c39f71452c08778"
  instance_type = "t2.micro"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4RPXBFIDYY54BH4P"
  secret_key = "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"
}
}


resource "aws_vpc" "btc-vpc" {
  cidr_block = "10.3.0.0/16"

  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "pub-a" {
  # for_each = var.subnets
  #name = each.value["key"]
  cidr_block              = "10.3.1.0/24"
  vpc_id                  = aws_vpc.btc-vpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-sbn-a"
  }
}

resource "aws_subnet" "pub-b" {
  vpc_id                  = aws_vpc.btc-vpc.id
  cidr_block              = "10.3.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-sbn-b"
  }
}


resource "aws_subnet" "pvt-a" {
  vpc_id            = aws_vpc.btc-vpc.id
  cidr_block        = "10.3.3.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "dev-pvt-a"
  }
}

resource "aws_subnet" "pvt-c" {
  vpc_id            = aws_vpc.btc-vpc.id
  cidr_block        = "10.3.4.0/24"
  availability_zone = "us-east-1a"


  tags = {
    Name = "dev-pvt-c"
  }
}

resource "aws_subnet" "pvt-b" {
  vpc_id            = aws_vpc.btc-vpc.id
  cidr_block        = "10.3.5.0/24"
  availability_zone = "us-east-1b"


  tags = {
    Name = "dev-pvt-b"
  }
}

resource "aws_subnet" "pvt-d" {
  vpc_id            = aws_vpc.btc-vpc.id
  cidr_block        = "10.3.6.0/24"
  availability_zone = "us-east-1b"


  tags = {
    Name = "dev-pvt-d"
  }
}



resource "aws_internet_gateway" "btc-igw" {
  vpc_id = aws_vpc.btc-vpc.id

  tags = {
    Name = "btc-igw"
  }
}


resource "aws_nat_gateway" "btc-ngw" {
  subnet_id = aws_subnet.pub-a.id
  connectivity_type = "public"
  tags = {
    Name = "btc-ngw"
  }

  /* # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.btc-igw]*/
}


variable "subnet_ids_pub" {
  type = list(string)
  default = ([
    "aws_subnet.pub-a.id",
    "aws_subnet.pub-b.id",
  ])
}


variable "subnet_ids_pvt" {
  type = list(string)
  default = ([
    "aws_subnet.pvt-a.id",
    "aws_subnet.pvt-b.id",
    "aws_subnet.pvt-c.id",
    "aws_subnet.pvt-d.id",
  ])
}
/*resource "aws_instance" "server" {
  for_each = local.subnet_ids

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  subnet_id     = each.key # note: each.key and each.value are the same for a set

  tags = {
    Name = "Server ${each.key}"
  }
}*/


resource "aws_route_table" "btc-pub-rt" {
  vpc_id = aws_vpc.btc-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.btc-igw.id
  }


  tags = {
    Name = "btc-pub-rt"
  }
}

resource "aws_route_table" "btc-pvt-rt" {
  vpc_id = aws_vpc.btc-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_internet_gateway.btc-igw.id
  }


  tags = {
    Name = "btc-pvt-rt"
  }
}

