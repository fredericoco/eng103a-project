provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "eng103a_project_jenkins" {
  ami                         = "ami-0f0dc86dc092baf66"
  instance_type               = "t2.medium"
  key_name                    = "eng103a_project"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-04a69c02cb3fc5c9b"]
  subnet_id                   = "subnet-07fcfefd61a8b9540"

  tags = {
    Name = "eng103a_project_jenkins"
  }
}
