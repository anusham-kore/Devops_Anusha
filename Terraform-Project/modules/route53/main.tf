resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = "app-services.kore.ai"
  type    = "CNAME"
  ttl     = 30
  records = [var.nlb_dns]
}