// LAUNCH TEMPLATE
# resource "aws_launch_template" "lt-1" {
#   name          = "launch_template-1"
#   vpc_security_group_ids = [aws_security_group.tf-sg1.id]

#   depends_on = [
#     aws_security_group.tf-sg1
#   ]
# }

// SECURITY GROUP
resource "aws_security_group" "tf-sg1" {
  name        = "EKS-SG"
  vpc_id      = var.vpc-id
  description = "Security Group for EKS worker nodes"

  ingress {
    description = "ALL"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "ALL"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

}