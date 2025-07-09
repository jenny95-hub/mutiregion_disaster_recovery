terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "${var.name_prefix}-lt"
  image_id      = var.ami_id
  instance_type = "t3.micro"

  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
  }

   user_data = base64encode(<<-EOF
  #!/bin/bash
  apt update -y
  apt install -y apache2
  sleep 10
  systemctl enable apache2
  systemctl start apache2

  cat <<EOT > /var/www/html/index.html
  <!DOCTYPE html>
  <html>
  <head><title>Welcome</title></head>
  <body>
    <h1>Welcome to ${var.name_prefix} Session</h1>
    <img src="${var.image_url}" alt="Welcome" />
  </body>
  </html>
  EOT
EOF
)
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.name_prefix}-asg"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = var.public_subnet_ids
  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }
 target_group_arns = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  tag{
    
      key                 = "Name"
      value               = "${var.name_prefix}-asg-instance"
      propagate_at_launch = true
    
  }
}