
resource "aws_lb" "alb" {
  name            = "ecs-django"
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets
}

output "alb-dns" {
  value = aws_lb.alb.dns_name
}

resource "aws_lb_target_group" "tg" {
  name        = "ecs-django-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "8000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
