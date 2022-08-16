terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
      }
    }
}

provider "aws" {
    region = "us-east-2"  
}

resource "aws_vpc" "sailorvpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "sailorvpc"
    } 
}

resource "aws_subnet" "sailorpubsn" {
    vpc_id = aws_vpc.sailorvpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
      Name = "sailorpubsn"
    }
}

resource "aws_internet_gateway" "sailorig" {
    vpc_id = aws_vpc.sailorvpc.id
    tags = {
      Name = "sailorig"
    }
}

resource "aws_route_table" "sailorigroutetable" {
  vpc_id = aws_vpc.sailorvpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sailorig.id
  }
}

resource "aws_route_table_association" "sailorroute_association" {
  route_table_id = aws_route_table.sailorigroutetable.id
  subnet_id      = aws_subnet.sailorpubsn.id
}

resource "aws_security_group" "sailorsg" {
   vpc_id=aws_vpc.sailorvpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
      from_port   = "8080"
      to_port     = "8080"
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "sailorsg"
    }
}

resource "aws_key_pair" "devopskey" {
    key_name = "devopskp" 
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDCizdZrseI76b0DyUcx89Yd5ZbaHfVd+C445qOQp5+3FgYc/YrUSLwpKxladO8O4FdqgQHKJSxTp3HytzzA0AqOzelIDfc5jNLvmgndAOwfJiXShkDpiV9Cng0IDhMEWmKakNHsPdwuwwyWANRByXdtGGC5UqqHhYVQT3Q4lTm5+57aUOqkvIZBJfOBl2xne1iCHw6BHqEPzCFE+BGeQoV97xxwq4/MIBoGjVVx4UodBvCvpcPHtbzdcDincKKFNpVOmdAUvibeMe0RFWvbfX6308+zQIW4kK1ElxDuxqiMADQ2juPZeJE4odOYpQUHFwlcNCwLOz7agvRFqEhk9PaovRkg8zGPcIjHfgfLXf3VIWRlTfAahGVQH4aEcKuBPcI0fHGfwd6hyNDc9bSok/j5W6xkv5HgsWgAHH8+fLTzJJACRoY1CcdOD+tSXZWRjq5DOrCZQamLwO8HmUyt9yixUka484t+o+dlmaMutsPJzh4LS+CGZdH9PQnIiuViTE= 91738@DESKTOP-401QIT9"
}

resource "aws_instance" "sailorec2" {
    subnet_id = aws_subnet.sailorpubsn.id
    vpc_security_group_ids = [aws_security_group.sailorsg.id]
    instance_type = "t2.micro"
    ami = "ami-02f3416038bdb17fb"
    associate_public_ip_address = true
    key_name = aws_key_pair.devopskey.key_name
    tags = {
        Name = "sailorec2"
    }
}
