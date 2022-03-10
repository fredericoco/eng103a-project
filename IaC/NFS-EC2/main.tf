provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "eng103a_project_nfs" {
  ami                         = "ami-08ca3fed11864d6bb"
  instance_type               = "t2.micro"
  key_name                    = "eng103a_project"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-021543900a1bfb761"]
  subnet_id                   = "subnet-0e68d0739fe9c0af0"

  root_block_device {
    volume_size           = "20"
    volume_type           = "io1"
    iops                  = 400
    encrypted             = false
    delete_on_termination = true
  }

  tags = {
    Name = "eng103a_project_nfs"
  }
}
