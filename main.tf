provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2_instance_1" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  key_name      = "agoresch"
  subnet_id     = "subnet-031018a2a183467bc"

  #This section would be where apache, php, and mysql client is installed on the ec2 instance
  # However, when this user_data section is used the target_group nodes report unhealthy
  #user_data = <<-EOF
             #!/bin/bash
             # sudo apt-get update
             # sudo apt-get install -y apache2 php libapache2-mod-php mysql-client

             # Restart Apache to apply changes
             # sudo service apache2 restart

             # Create index.html file
             #echo "<html><body>Alex Goresch was here</body></html>" | sudo tee /var/www/html/index.html
           #EOF

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y python3
              echo "<html><body>Alex Goresch was here</body></html>" > index.html
              nohup python3 -m http.server 80 &
            EOF

  tags = {
    Name = "EC2_Instance_1"
  }
}

resource "aws_instance" "ec2_instance_2" {
  ami           = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  key_name      = "agoresch"
  subnet_id     = "subnet-031018a2a183467bc"

  #This section would be where apache, php, and mysql client is installed on the ec2 instance
  # However, when this user_data section is used the target_group nodes report unhealthy
  #user_data = <<-EOF
           #!/bin/bash
           #sudo apt-get update
           #sudo apt-get install -y apache2 php libapache2-mod-php mysql-client

           # Restart Apache to apply changes
           #sudo service apache2 restart

           # Create index.html file
           #echo "<html><body>Alex Goresch was here</body></html>" | sudo tee /var/www/html/index.html
          #EOF

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y python3
              echo "<html><body>Alex Goresch was here</body></html>" > index.html
              nohup python3 -m http.server 80 &
            EOF

  tags = {
    Name = "EC2_Instance_2"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-0d111272ba929d350"]

  enable_deletion_protection = false

  subnets = ["subnet-031018a2a183467bc", "subnet-01972dd6a47ac1b68"]
}

resource "aws_lb_target_group" "target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-09045f0553d28d4c6"
}

resource "aws_lb_target_group_attachment" "ec2_instance_attachment_1" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.ec2_instance_1.id
}

resource "aws_lb_target_group_attachment" "ec2_instance_attachment_2" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.ec2_instance_2.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_db_instance" "mysql_db_instance" {
  identifier             = "my-mysql-db-instance"
  allocated_storage     = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = "adminpassword"
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = false
  skip_final_snapshot    = true
  backup_retention_period = 7
  storage_type           = "gp2"
  vpc_security_group_ids = ["sg-0d111272ba929d350"]
}
