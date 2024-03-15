resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "tfsn1" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
 availability_zone = "us-east-1a"
  tags = {
    Name = "sn1"
  }
}
resource "aws_subnet" "tfsn2" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
 availability_zone = "us-east-1b"
  tags = {
    Name = "sn2"
  }
}
resource "aws_internet_gateway" "tfigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "demoigw"
  }
}
resource "aws_route_table" "tfpubrt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tfigw.id
  }

  tags = {
    Name = "demopubrt"
  }
}
resource "aws_route_table_association" "tfrtassosn1" {
  subnet_id      = aws_subnet.tfsn1.id
  route_table_id = aws_route_table.tfpubrt.id
}
resource "aws_route_table_association" "tfrtassosn2" {
  subnet_id      = aws_subnet.tfsn2.id
  route_table_id = aws_route_table.tfpubrt.id
}
resource "aws_security_group" "application_sg" {
  name        = "appication_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "SHH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application-sg"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "mysql/auroa"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "SHH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-sg"
  }
}


resource "aws_instance" "application_app" {
  ami                          = "ami-07d9b9ddc6cd8dd30"
  instance_type                = "t2.small"
  subnet_id                    = aws_subnet.tfsn1.id
  vpc_security_group_ids       = [aws_security_group.application_sg.id]
  key_name                     = "Anto"
  associate_public_ip_address  =  "true"
  tags = {
    Name = "application_app"
  }
}

resource "aws_instance" "database" {
  ami                          = "ami-07d9b9ddc6cd8dd30"
  instance_type                = "t2.small"
  subnet_id                    = aws_subnet.tfsn2.id
  vpc_security_group_ids       = [aws_security_group.database_sg.id]
  key_name                     = "Anto"
  associate_public_ip_address  =  "true"
  tags = {
    Name = "Database"
  }
}