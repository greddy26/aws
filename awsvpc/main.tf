resource "aws_vpc" "nvpc" {
    cidr_block = var.nvpc_cidr
    tags = {
      "Name" = "nvpc"
    }
}
resource "aws_subnet" "nvpc_subnets" {
    count = length(var.nvpc_subnet_azs)
    cidr_block = cidrsubnet(var.nvpc_cidr, 8, count.index)
    availability_zone = var.nvpc_subnet_azs[count.index]
    vpc_id = aws_vpc.nvpc.id
    tags = {
        Name = var.nvpc_subnet_tags [count.index]
    }
  
}
resource "aws_internet_gateway" "nvpcigw" {
    vpc_id = aws_vpc.nvpc.id
    tags = {
        "Name" = "nvpcigw"
    }
    depends_on = [
      aws_vpc.nvpc
    ]
  
}
resource "aws_route_table" "publicrt" {
    vpc_id = aws_vpc.nvpc.id
    route = []
    tags = {
      "Name" = "publicrt"
    }
    depends_on = [
      aws_vpc.nvpc
    ]
  
}
resource "aws_route" "publicroute" {
    route_table_id = aws_route_table.publicrt.id
    
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.nvpcigw.id
}
resource "aws_route_table_association" "publicrtass" {
    count = length(var.web_subnet_indexes)
    subnet_id = aws_subnet.nvpc_subnets[var.web_subnet_indexes[count.index]]
    route_table_id = aws_route_table.publicrt.id
  
}
resource "aws_route_table" "privatert" {
    vpc_id = aws_vpc.nvpc.id
    tags = {
      "Name" = "privatert"
    }
  depends_on = [
    aws_subnet.nvpc_subnets
  ]
}
resource "aws_route_table_association" "privatertass" {
    count = length(var.other_subnet_indexes)
    subnet_id = aws_subnet.nvpc_subnets[var.other_subnet_indexes[count.index]]
    route_table_id = aws_route_table.privatert.id
  
}
resource "aws_security_group" "websg" {
    name = "openhttp"
    description = "openhttp and ssh"
    vpc_id = aws_vpc.nvpc.id
    tags = {
        "Name" = "openhttp"
    }
    depends_on = [
      aws_subnet.nvpc_subnets,
      aws_route_table.publicrt
    ]
  
}
resource "aws_security_group_rule" "websghttp" {
    type = "ingress"
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
    security_group_id = aws_security_group.websg.id  
}
resource "aws_security_group_rule" "websgssh" {
     type = "ingress"
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/16"]
    security_group_id = aws_security_group.websg.id 
  
}
resource "aws_instance" "webserver" {
    ami = "ami-0c1a7f89451184c8b"
    instance_type = "t2.micro"
    associate_public_ip_address = "true"
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id = aws_subnet.nvpc_subnets[0].id
  
}