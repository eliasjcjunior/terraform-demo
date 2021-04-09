locals {
  public_subnets_cidrs  = [cidrsubnet(var.cidr_block, 8, 0), cidrsubnet(var.cidr_block, 8, 2)]
  private_subnets_cidrs = [cidrsubnet(var.cidr_block, 8, 1), cidrsubnet(var.cidr_block, 8, 3)]
}


resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.azs[count.index]
  cidr_block        = local.public_subnets_cidrs[count.index]
  tags = {
    Name = "${var.name}-public-${var.azs[count.index]}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.azs[count.index]
  cidr_block        = local.private_subnets_cidrs[count.index]
  tags = {
    Name = "${var.name}-private-${var.azs[count.index]}"
  }
}

resource "aws_internet_gateway" "gw" {
  depends_on = [aws_vpc.main]

  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "nat" {
  count = length(var.azs)
  vpc   = true
  tags = {
    Name = "${var.name}-${var.azs[count.index]}"
  }
}

resource "aws_nat_gateway" "gw" {
  count         = length(var.azs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.name}-${var.azs[count.index]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.name
  }
}

resource "aws_route_table" "private" {
  count  = length(var.azs)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-private-${var.azs[count.index]}"
  }
}

resource "aws_route_table_association" "public" {
  depends_on = [aws_subnet.public, aws_route_table.public]
  count      = length(var.azs)

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route_table_association" "private" {
  depends_on = [aws_subnet.public, aws_route_table.private]
  count      = length(var.azs)

  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}

resource "aws_route" "public" {
  depends_on = [aws_route_table.public]

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route" "private" {
  count      = length(var.azs)
  depends_on = [aws_route_table.private]

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.gw[count.index].id
}

resource "aws_security_group" "lb" {
  name        = "Allow LB"
  description = "Allow LB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Request from load balancer"
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

resource "aws_security_group" "service" {
  name        = "Allow Service"
  description = "Allow Service"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Request from load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
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