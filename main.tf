# Creating vpc along with configurations.
# vpc with two subnets(public and private)
# AWs Provider Configuration

provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

#Providing vpc CIDR range
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }
}

# Create Internt Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
  tags = {
    Name = "${var.IGW_name}"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
   vpc_id     ="${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-2a"
    tags = {
    Name = "${var.public_subnet_name}"
  }
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
 vpc_id     ="${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-east-2a"
     tags = {
    Name = "${var.private_subnet_name}"
  }
}

# Create EIP for NAT gateway
resource "aws_eip" "default" {
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.default.id
  subnet_id = aws_subnet.private_subnet.id
}

# Create CMK key
resource "aws_kms_key" "cmk" {
  description = "cmk-kms-key"
    tags = {
    Name = "CMS_Nimesa_key"
  }
}


# Create RDS instance in private subnet
resource "aws_db_instance" "database" {
  engine = "mysql"
  instance_class = "db.t2.micro"
  allocated_storage = 10
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  availability_zone = "us-east-2a"
  storage_encrypted = true
  kms_key_id = aws_kms_key.cmk.id
}

# Create DB subnet group
resource "aws_db_subnet_group" "db_group" {
  name = "nimesa_db_subnet_group"
  subnet_ids = [
   aws_subnet.private_subnet.id
  ]
}
