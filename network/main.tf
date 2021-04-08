locals {
  public_subnets_cidrs  = [cidrsubnet(var.cidr_block, 8, 0), cidrsubnet(var.cidr_block, 8, 2)]
}


resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  count = length(var.azs)
  vpc_id     = aws_vpc.main.id
  cidr_block = local.public_subnets_cidrs[count.index]
  tags = {
    Name = "${var.name}-${var.azs[count.index]}"
  }
}

resource "aws_internet_gateway" "gw" {
  depends_on = [aws_vpc.main]

  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

resource "aws_route_table" "route" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

resource "aws_route_table_association" "a" {
  depends_on = [aws_subnet.public, aws_route_table.route]
  count      = length(var.azs)

  route_table_id = aws_route_table.route.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route" "r" {
  depends_on = [aws_route_table.route]

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.route.id
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_security_group" "service" {
  name        = "Allow Service"
  description = "Allow Service"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Request from public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}