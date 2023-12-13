#creating ssh key pair

resource "aws_key_pair" "my_key" {

  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("mykey.pub")
  tags = {
    "Name" = "${var.project_name}-${var.project_env}"
  }
}

#creating security groups

resource "aws_security_group" "frontend" {
  name        = "${var.project_name}-${var.project_env}-frontend"
  description = "${var.project_name}-${var.project_env}-frontend"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  #------promethous port----------

  ingress {
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-frontend"
  }
}

# Backend security group

resource "aws_security_group" "backend" {
  name        = "${var.project_name}-${var.project_env}-backend"
  description = "${var.project_name}-${var.project_env}-backend"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-backend"
  }
}

# creating Ec2 Instance- frontend

resource "aws_instance" "frontend" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_key.key_name
  user_data              = file("setup.sh")
  vpc_security_group_ids = [aws_security_group.frontend.id]
  tags = {
    "Name" = "${var.project_name}-${var.project_env}-frontend"
  }
}



# EC2 frontend elastic-ip


resource "aws_eip" "frontend" {
  instance = aws_instance.frontend.id
  domain   = "vpc"
  tags = {
    "Name" = "${var.project_name}-${var.project_env}-frontend"
  }
}


# create record frontend


resource "aws_route53_record" "frontend" {

  zone_id = data.aws_route53_zone.zone-details.id
  name    = "${var.host_name}.${var.hosted_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.frontend.public_ip]
}

