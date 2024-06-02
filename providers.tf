provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["/kube-mnt/home/ec2-user/.aws/credentials"]
  profile                  = "shadi"
}