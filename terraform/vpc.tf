resource "aws_vpc" "app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "app-vpc" }
}

resource "aws_subnet" "app_public" {
  vpc_id                  = aws_vpc.app.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags                    = { Name = "app-public" }
}

resource "aws_subnet" "app_private" {
  vpc_id            = aws_vpc.app.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "app-private" }
}

resource "aws_internet_gateway" "app" {
  vpc_id = aws_vpc.app.id
  tags   = { Name = "app-igw" }
}

resource "aws_route_table" "app_public" {
  vpc_id = aws_vpc.app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app.id
  }
  tags = { Name = "app-public-rt" }
}

resource "aws_route_table_association" "app_public" {
  subnet_id      = aws_subnet.app_public.id
  route_table_id = aws_route_table.app_public.id
}

resource "aws_route_table" "app_private" {
  vpc_id = aws_vpc.app.id
  tags   = { Name = "app-private-rt" }
}

resource "aws_route_table_association" "app_private" {
  subnet_id      = aws_subnet.app_private.id
  route_table_id = aws_route_table.app_private.id
}

#--  Data VPC 
resource "aws_vpc" "data" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "data-vpc" }
}

resource "aws_subnet" "data_private" {
  vpc_id            = aws_vpc.data.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "data-private" }
}

resource "aws_route_table" "data_private" {
  vpc_id = aws_vpc.data.id
  tags   = { Name = "data-private-rt" }
}

resource "aws_route_table_association" "data_private" {
  subnet_id      = aws_subnet.data_private.id
  route_table_id = aws_route_table.data_private.id
}

# -- shared services vpc
resource "aws_vpc" "shared" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "shared-vpc" }
}

resource "aws_subnet" "shared_private" {
  vpc_id            = aws_vpc.shared.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "shared-private" }
}

resource "aws_route_table" "shared_private" {
  vpc_id = aws_vpc.shared.id
  tags   = { Name = "shared-private-rt" }
}

resource "aws_route_table_association" "shared_private" {
  subnet_id      = aws_subnet.shared_private.id
  route_table_id = aws_route_table.shared_private.id
}