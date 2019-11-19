variable "VPC_CIDR" {}

variable "VPC_CIDRS" {
  type = map(string)
}

# VIRTUAL PRIVATE NETWORK
# =================================================================================

resource "aws_vpc" "vpc" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true # A boolean flag to enable DNS hostnames in the VPC

  tags = {
    Name = "OpenVPN VPC"
  }
}

# INTERNET GATEWAY
# =================================================================================
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IG"
  }
}

# ROUTE TABLES
# =================================================================================
resource "aws_default_route_table" "vpc_public_routes" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  tags = {
    Name = "VPC PUBLIC ROUTES"
  }
}

resource "aws_route_table" "vpc_private_routes" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "VPC PRIVATE ROUTES"
  }
}

# SUBNET
# =================================================================================
resource "aws_subnet" "vpc_public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.VPC_CIDRS["public"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "PUBLIC SUBNET 1"
  }
}

resource "aws_subnet" "vpc_private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.VPC_CIDRS["private"]
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "PRIVATE SUBNET 1"
  }
}

# SUBNET ASSOCIATION
# =================================================================================
resource "aws_route_table_association" "vpc_public_assoc" {
  subnet_id      = aws_subnet.vpc_public_subnet.id
  route_table_id = aws_default_route_table.vpc_public_routes.id
}

resource "aws_route_table_association" "vpc_private_assoc" {
  subnet_id      = aws_subnet.vpc_private_subnet.id
  route_table_id = aws_route_table.vpc_private_routes.id
}

