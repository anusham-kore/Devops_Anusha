resource "aws_lb" "nlb" {
  name               = "k8s-ingress"
  load_balancer_type = "network"
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "tg" {
  name     = "k8s-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}