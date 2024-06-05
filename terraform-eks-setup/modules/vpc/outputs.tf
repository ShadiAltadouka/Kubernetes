output "vpc-id" {
    value = aws_vpc.tf-kube-vpc.id
  
}

output "subnet-1" {
    value = aws_subnet.tf-subnet1.id
  
}

output "subnet-2" {
    value = aws_subnet.tf-subnet2.id
  
}
