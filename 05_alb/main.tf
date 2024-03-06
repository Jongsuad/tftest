# 시작 템플릿 
resource "aws_launch_template" "example" {
  name                   = "aws17-example-tamplate"
  image_id               = "ami-08fad555456323fb3"
  instance_type          = "t2.micro"
  key_name               = "aws17-key"
  vpc_security_group_ids = [aws_security_group.web.id, aws_security_group.ssh.id]

  user_data = base64encode(data.template_file.web_output.rendered)

  lifecycle {
    create_before_destroy = true
  }
}
# 오토스케일링 그룹
resource "aws_autoscaling_group" "example" {
  availability_zones = ["ap-northeast-2a", "ap-northeast-2c"]
  # vpc_zone_identifier = ["subnet-0f02b373f7f78e4a2","subnet-09f682d70ced2e4a1"]
  # vpc_zone_identifier = [var.subnet-2a,var.subnet-2c]
  name             = "aws17-asg-example"
  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "aws17-asg-example"
    propagate_at_launch = true


  }
}
# 로드밸런스 
resource "aws_lb" "example" {
  name               = "aws17-alb-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}
# resource "aws_lb" "example" {
#   name               = "aws17-alb-example"
#   load_balancer_type = "application"
#   subnets            = data.aws_subnets.default.ids
#   security_groups    = [aws_security_group.alb.id]
# }

# resource "aws_security_group" "alb" {
#   name        = "aws17-example-alb"
#   description = "Security group for ALB"
  
#   // 필요한 보안 그룹 설정을 추가하세요
# }

# lb 리스너 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404

    }
  }

}
# lb 리스너 룰 
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
  condition {
    path_pattern {
      values = ["*"]

    }
  }

}

# 대상그룹
resource "aws_lb_target_group" "asg" {
  name     = "aws17-target-group-example"
  port     = var.web_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2

  }
}
resource "aws_security_group" "alb" {
  name = "aws16-sg-example-alb"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 보안그룹 
resource "aws_security_group" "web" {
  name = "aws17-example-web"
  #vpc_id = var.vpc-id

  ingress {
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ssh" {
  name = "aws17-example-ssh"
  #vpc_id = var.vpc-id

  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "template_file" "web_output" {
  template = file("${path.module}/web.sh")
  vars = {
    web_port = "${var.web_port}"
  }
}