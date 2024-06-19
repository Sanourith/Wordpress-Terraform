### VPC

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

### SUBNETS

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az[0]
  tags = {
    Name = var.sub1name
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az[1]
  tags = {
    Name = var.sub2name
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.az[0]
  tags = {
    Name = var.priv1name
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = var.az[1]
  tags = {
    Name = var.priv2name
  }
}

resource "aws_subnet" "private_db_subnet" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = var.az[0]
}
resource "aws_subnet" "private_db_subnet2" {
  vpc_id = aws_vpc.app_vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = var.az[1]
}

resource "aws_db_subnet_group" "main" {
  name       = "db-subnet-group"
  subnet_ids = [
    # aws_subnet.private_subnet_a.id,
    # aws_subnet.private_subnet_b.id
    aws_subnet.private_db_subnet.id,
    aws_subnet.private_db_subnet2.id
  ]

  tags = {
    Name = "main-db-subnet-group"
  }
}

### IGW

resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app-gateway"
  }
}

# ------------------------------------------------

### ROUTES TABLES VERS LE RESEAU

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
  tags = {
    Name = "app-public-rtb"
  }
}

### LIAISONS TABLES-RESEAUX

resource "aws_route_table_association" "rta_subnetass_puba" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.rtb_public.id
}
resource "aws_route_table_association" "rta_subnetass_pubb" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.rtb_public.id
}

# NAT GATEWAY

resource "aws_eip" "eip_public_a" {
  domain = "vpc"
}
resource "aws_eip" "eip_public_b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "gw_pub_a" {
  allocation_id = aws_eip.eip_public_a.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags = {
    Name = "app_ngw_a"
  }
}

resource "aws_nat_gateway" "gw_pub_b" {
  allocation_id = aws_eip.eip_public_b.id
  subnet_id     = aws_subnet.public_subnet_b.id
  tags = {
    Name = "app_ngw_b"
  }
}

### TABLES DE ROUTAGE VERS L'APP

resource "aws_route_table" "private-a" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_pub_a.id
  }
  tags = {
    Name = "private-routetable"
  }
}
resource "aws_route_table" "private-b" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_pub_b.id
  }
  tags = {
    Name = "private-routetable"
  }
}
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw_pub_a.id
  }
  tags = {
    Name = "private-db-rtb"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private-a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private-b.id
}

# resource "aws_route_table_association" "private_db" {
#   route_table_id = aws_route_table.private_db.id
#   subnet_id = aws_db_subnet_group.main.id
# }
 
### NACL 

resource "aws_network_acl" "nacl_publica" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "ACL-app"
  }
}

resource "aws_network_acl_rule" "nat_inbounda" {
  network_acl_id = aws_network_acl.nacl_publica.id
  rule_action    = "allow"
  rule_number    = 200
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl" "nacl_publicb" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "ACL-app2"
  }
}

resource "aws_network_acl_rule" "nat_inboundb" {
  network_acl_id = aws_network_acl.nacl_publicb.id
  rule_action    = "allow"
  rule_number    = 300
  protocol       = "-1"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}
