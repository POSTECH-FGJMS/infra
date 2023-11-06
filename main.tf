terraform {
  backend "s3" {
    bucket         = "lanchonete-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lanchonete-terraform-state"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_db_subnet_group" "public_db_subnet_group" {
  name       = "public-db-subnet-group"
  subnet_ids = ["${var.subnet_id1}", "${var.subnet_id2}"]
}

resource "aws_security_group" "public_rds_sg" {
  name        = "public-rds-sg"
  description = "Security group for RDS instance with public access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "lanchonete_rds" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.t3.micro"
  db_name              = "lanchonete"
  identifier           = "lanchonete-rds"
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  publicly_accessible  = true
  db_subnet_group_name = aws_db_subnet_group.public_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.public_rds_sg.id]
}

