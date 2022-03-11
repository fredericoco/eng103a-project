provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "eng103a_project_k8_master" {
  # if needed ami-002d271e1d667684b
  ami                         = "ami-08ca3fed11864d6bb"
  instance_type               = "t2.medium"
  key_name                    = "eng103a_project"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-0d6ce5401866a0b04"]
  subnet_id                   = "subnet-065a0ff785a6dc741"

  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  tags = {
    Name = "eng103a_project_k8_master"
  }
}
