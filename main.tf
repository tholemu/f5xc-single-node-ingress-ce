provider "aws" {
  # Configuration options
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "prod_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "production-vpc"
    }
}

resource "aws_subnet" "public_net" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.prod_vpc.cidr_block, 8, 200 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.prod_vpc.id
  map_public_ip_on_launch = false

  tags = {
    "Name" = "public-net"
  }
}

resource "aws_subnet" "private_net" {
  count             = 2
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.prod_vpc.cidr_block, 8, 100 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    "Name" = "private-net"
  }
}

resource "aws_internet_gateway" "inet_gateway" {
  vpc_id = aws_vpc.prod_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id          = aws_vpc.prod_vpc.main_route_table_id
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = aws_internet_gateway.inet_gateway.id
}

resource "aws_eip" "eip_gateway" {
  count = 2
  vpc = true
  depends_on = [
    aws_internet_gateway.inet_gateway
  ]

  tags = {
    "Name" = "eip-gateway"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = 2
  subnet_id = element(aws_subnet.public_net.*.id, count.index)
  # subnet_id = element(aws_subnet.private_net.*.id, count.index)
  allocation_id = element(aws_eip.eip_gateway.*.id, count.index)

  tags = {
    "Name" = "nat-gw"
  }
}

resource "aws_route_table" "internal_routes" {
  count = 2
  vpc_id = aws_vpc.prod_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }

  tags = {
    "Name" = "internal-routes"
  }
}

resource "aws_route_table_association" "internal_route_association" {
  count = 2
  subnet_id = element(aws_subnet.private_net.*.id, count.index)
  route_table_id = element(aws_route_table.internal_routes.*.id, count.index)
}

resource "aws_security_group" "lb_sg" {
  name = "lb-sg"
  vpc_id = aws_vpc.prod_vpc.id

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    "Name" = "lb-sg"
  }
}

resource "aws_lb" "http_lb" {
  name = "http-lb"
  subnets = aws_subnet.private_net.*.id
  security_groups = [ aws_security_group.lb_sg.id ]

  tags = {
    "Name" = "http-lb"
  }
}

resource "aws_lb_target_group" "http_lb_target_group" {
  name = "http-lb-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = aws_vpc.prod_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "http_lb_listener" {
  load_balancer_arn = aws_lb.http_lb.id
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.http_lb_target_group.id
    type = "forward"
  }
}

resource "aws_security_group" "prod_task_sg" {
  vpc_id = aws_vpc.prod_vpc.id

  ingress {
    protocol = "tcp"
    from_port = 8000
    to_port = 8000
    security_groups = [ aws_security_group.lb_sg.id ]
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    "Name" = "prod-task-sg"
  }
}

### F5 Distributed Cloud CE ###

resource "random_id" "buildSuffix" {
  byte_length = 2
}

resource "tls_private_key" "newkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "newkey_pem" {
  # create a new local ssh identity
  filename        = "${abspath(path.root)}/.ssh/${var.project_prefix}-key-${random_id.buildSuffix.hex}.pem"
  content         = tls_private_key.newkey.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "deployer" {
  # create a new AWS ssh identity
  key_name   = "${var.project_prefix}-key-${random_id.buildSuffix.hex}"
  public_key = tls_private_key.newkey.public_key_openssh
  tags = {
    Owner = var.resource_owner
  }
}

resource "aws_network_interface" "f5xc_ce1_outside" {
  subnet_id                 = aws_subnet.public_net[0].id
  private_ips_count         = 1
  security_groups           = [aws_security_group.lb_sg.id]
  source_dest_check         = false
  private_ip_list_enabled   = false
  ipv6_address_list_enabled = false
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce1_outside-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_eip" "f5xc_ce1_outside" {
  vpc                       = true
  network_interface         = aws_network_interface.f5xc_ce1_outside.id
  associate_with_private_ip = aws_network_interface.f5xc_ce1_outside.private_ip
  tags = {
    Name  = "${var.project_prefix}-f5xc_ce1_outside_eipd-${random_id.buildSuffix.hex}"
    Owner = var.resource_owner
  }
}

resource "aws_instance" "f5xc_ce1" {
  ami           = var.amis[var.aws_region]
  instance_type = var.instance_type
  root_block_device {
    volume_size = var.instance_disk_size
    volume_type = "gp3"
  }
  get_password_data = false
  monitoring        = false
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  # user_data_replace_on_change = true
  user_data = templatefile("${path.module}/cloud_init.yaml.template",
    {
      sitetoken     = "${var.sitetoken}",
      clustername   = "${var.clustername}",
      sitelatitude  = "${var.sitelatitude}",
      sitelongitude = "${var.sitelongitude}",
      sitesshrsakey = "${tls_private_key.newkey.private_key_pem}"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.f5xc_ce1_outside.id
    device_index         = 0
  }
  # network_interface {
  #   network_interface_id = aws_network_interface.f5xc_ce1_inside.id
  #   device_index         = 1
  # }

  tags = {
    Name = "${var.project_prefix}-master-0"
  }
}

###############################
