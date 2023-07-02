data "aws_route53_zone" "existing_hosted_zone" {
  name = "ysahakyan.devopsaca.site"  # Replace with your domain name
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.existing_hosted_zone.id
}

data "external" "aws_cli_command" {
  program = ["bash", "-c", "aws ec2 describe-instances --region us-east-1 --output json"]
}

output "instance_details" {
  value = jsondecode(data.external.aws_cli_command.result)
}
