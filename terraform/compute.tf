resource "aws_security_group" "bastion" {
  name = "bastion-sg"
  vpc_id = aws_vpc.app.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app" {
  name = "app-sg"
  vpc_id = aws_vpc.app.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]    
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "data" {
  name = "data_sg"
  vpc_id = aws_vpc.data.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion" {
  ami = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.app_public.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name = var.key_name
  associate_public_ip_address = true
  tags = { Name = "bastion" }
}

resource "aws_instance" "app_server" {
  ami = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.app_private.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name = var.key_name
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www && echo "Hello from App server" > /var/www/index.html
    cd /var/www && nohup python3 -m http.server 80 &
  EOF
  tags = { Name = "app-server" }
}

resource "aws_instance" "data_server" {
  ami = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.data_private.id
  vpc_security_group_ids = [aws_security_group.data.id]
  key_name = var.key_name
  user_data = <<-EOF
    #!/bin/bash
    mkdir -p /var/www && echo "Hello from data server" > /var/www/index.html
    cd /var/www && nohup python3 -m http.server 80 &
  EOF
  tags = { Name = "data_server" }
}