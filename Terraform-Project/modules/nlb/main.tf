resource "aws_lb" "nlb" {
  name               = var.name
  load_balancer_type = "network"
  subnets            = var.public_subnets
  tags               = var.tags
}

resource "aws_lb_target_group" "tg" {
  name     = var.target_group_name
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id
  tags     = var.tags
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
