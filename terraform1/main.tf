variable "lb_dns_name" {
  description = "The DNS name of the load balancer"
}

resource "aws_route53_record" "example" {
  zone_id = "Z057290428AHLJHX3Z6WE"
  name    = "api.ysahakyan.devopsaca.site"
  type    = "A"
  alias {
    name                   = var.lb_dns_name
    zone_id                = "Z35SXDOTRQ7X7K"
    evaluate_target_health = true
  }
}

#resource "aws_acm_certificate" "yapicert" {
#  private_key      = file("${path.module}/privkey1.pem")
#  certificate_body = file("${path.module}/cert1.pem")
#  certificate_chain = file("${path.module}/chain1.pem")
#}

#data "aws_lb" "lb" {
#  name = var.lb_dns_name
#}
#
#data "aws_lb_listener" "listener" {
#  load_balancer_arn = data.aws_lb.lb.arn
#}
#
#output "listener_arn" {
#  value = data.aws_lb_listener.listener.arn
#}
#
#resource "aws_lb_listener_certificate" "lb_certificate" {
#  listener_arn    = data.aws_lb_listener.listener.arn
#  certificate_arn = aws_acm_certificate.yapicert.arn
#}

