module "vpc" {
    source = "./modules/vpc"
}

module "lt-sg" {
    source = "./modules/launch-template-sg"
    vpc-id = module.vpc.vpc-id

    depends_on = [
        module.vpc
    ]
}

module "eks-iam" {
    source = "./modules/eks-iam"
    launch-template-id = module.lt-sg.launch-template-id
    launch-template-version = module.lt-sg.launch-template-version
    security-group-id = module.lt-sg.security-group-id
    subnet-1-id = module.vpc.subnet-1
    subnet-2-id = module.vpc.subnet-2

    depends_on = [
        module.lt-sg
        ]
}

# // Create an EBS volume
# resource "aws_ebs_volume" "example" {
#   availability_zone = "us-east-1a"
#   size              = 5
#   tags = {
#     Name = "example-ebs-volume"
#   }
# }
# output "volume_id" {
#   value = aws_ebs_volume.example.id
# }