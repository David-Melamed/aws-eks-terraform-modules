resource "aws_default_route_table" "internal_ekslab_default" {
  default_route_table_id = aws_vpc.ekslab.default_route_table_id

  route {
    cidr_block = var.rt_route_cidr_block
    gateway_id = aws_internet_gateway.ekslab_gw.id
  }
  tags = {
    Name = var.tags
  }
}

resource "aws_route_table_association" "default" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_ekslab_subnet[count.index].id
  route_table_id = aws_default_route_table.internal_ekslab_default.id
}
