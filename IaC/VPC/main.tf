provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "eng103a_project_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eng103a_project_vpc"
  }
}

resource "aws_subnet" "k8s_subnet_public_1a" {
  vpc_id                  = aws_vpc.eng103a_project_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "k8s_subnet_public_1a"
  }
}

resource "aws_subnet" "k8s_subnet_public_1b" {
  vpc_id                  = aws_vpc.eng103a_project_vpc.id
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "k8s_subnet_public_1b"
  }
}

resource "aws_subnet" "k8s_subnet_public_1c" {
  vpc_id                  = aws_vpc.eng103a_project_vpc.id
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1c"

  tags = {
    Name = "k8s_subnet_public_1c"
  }
}

resource "aws_subnet" "monitoring_subnet_public" {
  vpc_id                  = aws_vpc.eng103a_project_vpc.id
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "monitoring_subnet_public"
  }
}

resource "aws_subnet" "nfs_subnet_private" {
  vpc_id                  = aws_vpc.eng103a_project_vpc.id
  cidr_block              = "10.0.14.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "nfs_subnet_private"
  }
}

resource "aws_subnet" "cicd_subnet_public" {
  vpc_id                  = aws_vpc.eng103a_project_vpc.id
  cidr_block              = "10.0.15.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "cicd_subnet_public"
  }
}

# creates the gateway
resource "aws_internet_gateway" "eng103a_project_gateway" {
  vpc_id = aws_vpc.eng103a_project_vpc.id

  tags = {
    Name = "eng103a_project_gateway"
  }
}

# creates route table
resource "aws_route_table" "eng103a_project_route_table" {
  vpc_id = aws_vpc.eng103a_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.eng103a_project_gateway.id
  }

  tags = {
    Name = "eng103a_project_route_table"
  }
}

# creates associations between route table and subnets
resource "aws_route_table_association" "eng103a_route_table_association_1" {
  route_table_id = aws_route_table.eng103a_project_route_table.id
  subnet_id      = aws_subnet.cicd_subnet_public.id
}

resource "aws_route_table_association" "eng103a_route_table_association_2" {
  route_table_id = aws_route_table.eng103a_project_route_table.id
  subnet_id      = aws_subnet.k8s_subnet_public_1a.id
}

resource "aws_route_table_association" "eng103a_route_table_association_3" {
  route_table_id = aws_route_table.eng103a_project_route_table.id
  subnet_id      = aws_subnet.k8s_subnet_public_1b.id
}

resource "aws_route_table_association" "eng103a_route_table_association_4" {
  route_table_id = aws_route_table.eng103a_project_route_table.id
  subnet_id      = aws_subnet.k8s_subnet_public_1c.id
}

resource "aws_route_table_association" "eng103a_route_table_association_5" {
  route_table_id = aws_route_table.eng103a_project_route_table.id
  subnet_id      = aws_subnet.monitoring_subnet_public.id
}

resource "aws_route_table_association" "eng103a_route_table_association_6" {
  route_table_id = aws_route_table.eng103a_project_route_table.id
  subnet_id      = aws_subnet.nfs_subnet_private.id
}

# create security group (x3)
resource "aws_security_group" "eng103a_project_cicd_sg" {
  vpc_id = aws_vpc.eng103a_project_vpc.id

  # outbound rule
  egress = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "allow access from everywhere"
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  # inbound rules
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "ssh access from anywhere"
    from_port        = 22
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    },

    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "http access from anywhere"
      from_port        = 80
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow access on port 8080 from anywhere"
      from_port        = 8080
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 8080
  }]

  tags = {
    Name = "eng103a_project_cicd_sg"
  }

}

resource "aws_security_group" "eng103a_project_k8s_sg" {
  vpc_id = aws_vpc.eng103a_project_vpc.id

  # outbound rule
  egress = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "allow access from everywhere"
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  # inbound rules
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "ssh access from anywhere"
    from_port        = 22
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    },

    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "http access from anywhere"
      from_port        = 80
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow access on port 443 from anywhere"
      from_port        = 443
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443


    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow access on port 30000 - 32767 from anywhere"
      from_port        = 30000
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 32767
    },
    {
      cidr_blocks      = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24", "10.0.15.0/24"]
      description      = "allow access on port 6443 from anywhere"
      from_port        = 6443
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 6443
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow access on port 9443 from anywhere"
      from_port        = 9443
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 9443
    },
  ]
  tags = {
    Name = "eng103a_project_k8s_sg"
  }

}

resource "aws_security_group" "eng103a_project_nfs_sg" {
  vpc_id = aws_vpc.eng103a_project_vpc.id

  # outbound rule
  egress = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "allow access from everywhere"
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  # inbound rules
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "ssh access from anywhere"
    from_port        = 22
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    },

    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "http access from anywhere"
      from_port        = 2049
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 2049
    }
    #   {
    #     cidr_blocks      = ["0.0.0.0/0"]
    #     description      = "allow access on port 5000 from anywhere"
    #     from_port        = 5000
    #     ipv6_cidr_blocks = ["::/0"]
    #     prefix_list_ids  = []
    #     protocol         = "tcp"
    #     security_groups  = []
    #     self             = false
    #     to_port          = 5000
    # }
  ]
  tags = {
    Name = "eng103a_project_nfs_sg"
  }

}

resource "aws_security_group" "eng103a_project_monitoring_sg" {
  vpc_id = aws_vpc.eng103a_project_vpc.id

  # outbound rule
  egress = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "allow access from everywhere"
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  # inbound rules
  ingress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "ssh access from anywhere"
    from_port        = 22
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = []
    self             = false
    to_port          = 22
    },

    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "http access from anywhere"
      from_port        = 80
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "allow access on port 443 from anywhere"
      from_port        = 443
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow access on port 3000 from anywhere"
      from_port        = 3000
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 3000
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = "allow access on port 9090 from anywhere"
      from_port        = 9090
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 9090
  }, ]

  tags = {
    Name = "eng103a_project_monitoring_sg"
  }

}
