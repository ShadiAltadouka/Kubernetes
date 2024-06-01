provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["/home/ec2-user/.aws/credentials"]
  profile                  = "shadi"
}