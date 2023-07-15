resource "aws_acm_certificate" "ycert" {
  private_key      = file("${path.module}/privkey.pem")
  certificate_body = file("${path.module}/cert.pem")
  certificate_chain = file("${path.module}/chain.pem")
}

resource "aws_acm_certificate" "yapicert" {
  private_key      = file("${path.module}/privkey1.pem")
  certificate_body = file("${path.module}/cert1.pem")
  certificate_chain = file("${path.module}/chain1.pem")
}
