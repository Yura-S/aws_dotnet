resource "aws_route53_record" "example" {
  zone_id = "Z057290428AHLJHX3Z6WE"
  name    = "ysahakyan.devopsaca.site"
  type    = "A"

  alias {
    name                   = "s3-website-us-east-1.amazonaws.com."
    zone_id                = "Z3AQBSTGFYJSTF"
    evaluate_target_health = true
  }
}
