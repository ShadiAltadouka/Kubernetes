# variable "launch-template-id" {
#     description = "Launch template ID from launch-template-sg module output"
#     type = string
  
# }

# variable "launch-template-version" {
#     description = "Launch template LATEST-VERSION from launch-template-sg module output"
#     type = string
  
# }

variable "subnet-1-id" {
    description = "Subnet-1 ID from vpc module output"
    type = string
  
}

variable "subnet-2-id" {
    description = "Subnet-2 ID from vpc module output"
    type = string
  
}

variable "security-group-id" {
    description = "Security group ID from launch-template-sg module output"
    type = string
  
}