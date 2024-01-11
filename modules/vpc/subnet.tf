resource "aws_subnet" "public_ekslab_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.ekslab.id
  cidr_block              = var.public_cidrs[count.index]
  availability_zone       = random_shuffle.az_list.result[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = var.tags
  }
}