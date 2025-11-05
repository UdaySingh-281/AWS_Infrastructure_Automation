terraform {
  backend "s3" {
    bucket         = "uday2035-terraform-state-bucket"
    key            = "aws-infra/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}
