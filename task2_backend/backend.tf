terraform {
  backend "s3" {
    bucket         = "devops-assignment-tfstate-000000000000"
    key            = "task1-ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "devops-assignment-tfstate-locks"
    encrypt        = true
  }
}
