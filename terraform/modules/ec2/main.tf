resource "aws_security_group" "web_sg" {
  name        = "${var.env}-web-sg"
  description = "Allow HTTP/HTTPS from internet & SSH from Bastion"
  vpc_id      = var.vpc_id

  # HTTP Access (frontend)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from Internet"
  }

  # HTTPS (optional)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from Internet"
  }

  # SSH access only from Bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id]
    description     = "Allow SSH from Bastion host"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "db_sg" {
  name        = "${var.env}-db-sg"
  description = "Allow DB access from Web layer only"
  vpc_id      = var.vpc_id

  # Allow DB traffic only from Web SG
  ingress {
    from_port       = 3306  # MySQL port (adjust if different)
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    description     = "Allow MySQL from Web servers"
  }

  # Allow SSH only from Bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id]
    description     = "Allow SSH from Bastion host"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "bastion_host_sg" {
  name = "${var.env}-bastion-host-sg"
  description = "Allow SSH Access"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_instance" "web" {
  count = var.instance_count_app
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = var.public_subnet
  security_groups = [aws_security_group.web_sg.id]
  key_name = var.key_name
  tags = {
    Name = "${var.env}-web-instance-${count.index + 1}"
  }
}

resource "aws_instance" "db" {
  count = var.instance_count_db
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = var.private_subnet
  security_groups = [aws_security_group.db_sg.id]
  key_name = var.key_name
  tags = {
    Name = "${var.env}-db-instance-${count.index + 1}"
  }
}


resource "aws_instance" "bastion_host" {
  ami = var.ami
  instance_type = "t2.micro"
  subnet_id = var.public_subnet
  key_name = var.key_name
  security_groups = [aws_security_group.bastion_host_sg.id]
  tags = {Name = "${var.env}-bastion-host"}
}

resource "aws_eip" "bastion_host_eip" {
  instance = aws_instance.bastion_host.id
  domain = "vpc"

  tags = {
    Name = "${var.env}-bastion-host-eip"
  }  
}