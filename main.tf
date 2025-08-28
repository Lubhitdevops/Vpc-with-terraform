provider "aws" {
  region = "us-east-1"
}

# ---------------- VPC ----------------
#resource type    #resource referencename      
resource "aws_vpc" "Myvpc" {
  #resource arguments
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "lubhitvpc"
  }
}


# ---------------- Route Tables ----------------
resource "aws_route_table" "publicroutetable" {
  vpc_id = aws_vpc.Myvpc.id
  tags = {
    "Name" = "Mypublicroute"
  }
}
resource "aws_route_table" "privateroutetable" {
  vpc_id = aws_vpc.Myvpc.id
  tags = {
    "Name" = "Myprivateroute"
  }
}

# ---------------- Subnets ----------------
resource "aws_subnet" "mypublicsubnet01" {
  vpc_id            = aws_vpc.Myvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "My public subnet 01"
  }
}
resource "aws_subnet" "mypublicsubnet02" {
  vpc_id            = aws_vpc.Myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "My public subnet 02"
  }
}
resource "aws_subnet" "myprivatesubnet01" {
  vpc_id            = aws_vpc.Myvpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "My private subnet 01"
  }
}
resource "aws_subnet" "myprivatesubnet02" {
  vpc_id            = aws_vpc.Myvpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "My private subnet 02"
  }
}

# ---------------- Associations ----------------
resource "aws_route_table_association" "publicsubnet01association" {
  route_table_id = aws_route_table.publicroutetable.id
  subnet_id      = aws_subnet.mypublicsubnet01.id
}

resource "aws_route_table_association" "publicsubnet02association" {
  route_table_id = aws_route_table.publicroutetable.id
  subnet_id      = aws_subnet.mypublicsubnet02.id
}

resource "aws_route_table_association" "privatesubnet01association" {
  route_table_id = aws_route_table.privateroutetable.id
  subnet_id      = aws_subnet.myprivatesubnet01.id
}

resource "aws_route_table_association" "privatesubnet02association" {
  route_table_id = aws_route_table.privateroutetable.id
  subnet_id      = aws_subnet.myprivatesubnet02.id
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "MyIGW" {
  tags = {
    "Name" = "MYIGW"
  }
}

resource "aws_internet_gateway_attachment" "IGWAttachment" {
  internet_gateway_id = aws_internet_gateway.MyIGW.id
  vpc_id              = aws_vpc.Myvpc.id
}

resource "aws_route" "IGWroute" {
  route_table_id         = aws_route_table.publicroutetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.MyIGW.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.Myvpc.id
  name   = "ec2-security-group"

  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80 # HTTP
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
    "Name" = "ec2_sg"
  }
}

# ---------------- EC2 Instance ----------------
resource "aws_instance" "myec2" {
  ami                         = "ami-0c7217cdde317cfec" # Amazon Linux 2 in us-east-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.mypublicsubnet01.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  key_name = "tf-key"

  tags = {
    "Name" = "MyEC2Instance"
  }
}