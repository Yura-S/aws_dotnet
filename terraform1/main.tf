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
