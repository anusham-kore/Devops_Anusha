resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = "CNAME"
  ttl     = 30
  records = [var.nlb_dns]
}
