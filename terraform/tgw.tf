resource "aws_ec2_transit_gateway" "main" {
  description                     = "week4-lab-tgw"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  tags                            = { Name = "week4-tgw" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.app.id
  subnet_ids         = [aws_subnet.app_private.id]
  tags               = { Name = "tgw-attach-app" }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "data" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.data.id
  subnet_ids         = [aws_subnet.data_private.id]
  tags               = { Name = "tgw-attach-data" }
}

# Route app's private subnet to data VPC via IGW
resource "aws_route" "app_to_data" {
  route_table_id         = aws_route_table.app_private.id
  destination_cidr_block = "10.2.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.app]
}

resource "aws_route" "data_to_app" {
  route_table_id         = aws_route_table.data_private.id
  destination_cidr_block = "10.0.0.0/16"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.data]
}