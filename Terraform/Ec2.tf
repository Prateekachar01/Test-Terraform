#Creating the key pair
resource "aws_key_pair" "key" {
  key_name   = "key-pair-017"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Using Ubuntu-20 official AMI
data "aws_ami" "amazon_ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Create Bastion EC2 instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_ubuntu.id
  key_name                    = aws_key_pair.key.key_name
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.0.id
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]
  associate_public_ip_address = true

# Add a name tag to the instance
  tags = {
    Name = "Bastion-Instance-017"
  }
}

# Create Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_ubuntu.id
  key_name               = aws_key_pair.key.key_name
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.0.id
  vpc_security_group_ids = [aws_security_group.private_instance.id]
  associate_public_ip_address = false

# Add a name tag to the instance
  tags = {
    Name = "Jenkins-Instance-017"
  }

}

# Create App EC2 instance
resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_ubuntu.id
  key_name                    = aws_key_pair.key.key_name
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private.1.id
  vpc_security_group_ids      = [aws_security_group.private_instance.id]
  associate_public_ip_address = false

# Add a name tag to the instance
  tags = {
    Name = "App-Instance-017"
  }

}
