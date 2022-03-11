provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "eng103a_project_monitoring" {
  ami                         = "ami-07d8796a2b0f8d29c"
  instance_type               = "t2.micro"
  key_name                    = "eng103a_project"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-030bffaceb0a7d22c"]
  subnet_id                   = "subnet-0a49ee5ca93d6b622"
  tags = {
    Name = "eng103a_project_monitoring"
  }
}
