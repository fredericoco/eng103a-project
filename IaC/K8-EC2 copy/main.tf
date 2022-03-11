provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "eng103a_project_k8_worker_test" {
  ami                         = "ami-08ca3fed11864d6bb"
  instance_type               = "t2.micro"
  key_name                    = "eng103a_project"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-0d6ce5401866a0b04"]
  subnet_id                   = "subnet-065a0ff785a6dc741"
  tags = {
    Name = "eng103a_project_k8_worker_test"
  }
}
