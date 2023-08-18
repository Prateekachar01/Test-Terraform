# Using a http data source to get own IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

#Creating Security Group for Bastion Host

resource "aws_security_group" "bastion_host" {
  name        = "bastion-host-sg-017"
  description = "bastion-host-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create Security Group for Private Instance

resource "aws_security_group" "private_instance" {
  name        = "private-instance-sg-017"
  description = "private-instance-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Private"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create Security Group for Public Web
resource "aws_security_group" "public_web" {
  name        = "public-web-sg-017"
  description = "public-web-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
} 
