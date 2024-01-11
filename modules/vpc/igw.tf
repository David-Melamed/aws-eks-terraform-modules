resource "aws_internet_gateway" "ekslab_gw" {
  vpc_id = aws_vpc.ekslab.id

  tags = {
    Name = var.tags
  }
}