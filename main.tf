
output "instance_ip" {
  description = "The public ip for ssh access"
  value       = aws_eip.ubuntu.public_ip
}
#
#resource "aws_key_pair" "ssh-key" {
#  key_name   = "ssh-key"
#  public_key = file("~/.ssh/id_rsa.pub")
#}
#
#resource "aws_instance" "instance" {
#  instance_type    = "t2.micro"
#  associate_public_ip_address = true
#
#  key_name         = "ssh-key"
#}
#


provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_key_pair" "ubuntu" {
  key_name   = "ubuntu"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ubuntu" {
  name        = "ubuntu-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "terraform"
  }
}


resource "aws_instance" "ubuntu" {
  key_name      = aws_key_pair.ubuntu.key_name
  ami           = "ami-06e54d05255faf8f6"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu"
  }

  vpc_security_group_ids = [
    aws_security_group.ubuntu.id
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }
}

resource "aws_eip" "ubuntu" {
  vpc      = true
  instance = aws_instance.ubuntu.id
}
