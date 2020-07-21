# CIDR for the whole VPC
variable "vpcCIDRblock" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

#public vpcCIDRblock
variable "vpc-public-CIDRblock" {
    default = ["10.0.0.0/24", "10.0.2.0/24"]
    type = list
    description = "List of public subnet CIDR blocks"
}

#private vpcCIDRblock
variable "vpc-private-CIDRblock" {
    default = "10.0.0.0/24"
}

#DNSsupport
variable "DNSsupport" {
    default = true
}
#DNShostnames
variable "DNShostnames" {

    default = true
}

/*subnets
variable "subnets" {
    default = "0.0.0.0/0"
}
*/
variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "aws_key_name" {}

variable "region" {
     default = "us-east-1"
}

variable "amis" {

    description = "AMIs by region"
    default = {
        us-east-1 = "ami-b374d5a5"
    }
} 

variable "availability_zones" {
     default = ["us-east-1a", "us-east-1b"]
     type = list
     description = "List of availability zones"
}

