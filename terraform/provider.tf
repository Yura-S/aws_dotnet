provider "aws" {
  
  region = "us-east-1"

  default_tags {
    tags = {
      Owner     = "three_tier_app"
      Type      = "prod"
    }
  }
}
