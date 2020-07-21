provider "aws" {
    region = var.region
}

# create the VPC
resource "aws_vpc" "vpc" {
    cidr_block = var.vpcCIDRblock
    enable_dns_support = var.DNSsupport
    enable_dns_hostnames = var.DNShostnames
    tags = {
        Name = "my_vpc"
    }
}

# create the Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id 
    tags = {
        Name = "VPC_IGW"
    }
}

# create the Public Route Table
resource "aws_route_table" "rtbpublic" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name ="public_rtb"
    }
}

# Associate the public Route Table with the Public Subnet
resource "aws_route_table_association" "rtapublic" {
    count = length(var.vpc-public-CIDRblock)
    subnet_id = aws_subnet.vpc-public-CIDRblock[count.index].id
    route_table_id = aws_route_table.rtbpublic.id
}

# create the private Route Table
resource "aws_route_table" "rtbprivate" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        
    }

    tags = {
        Name ="private_rtb"
    }
}

# Associate the Private Route Table with the Private Subnet
resource "aws_route_table_association" "rtaprivate" {
    count = length(var.vpc-private-CIDRblock )
    subnet_id = aws_subnet.vpc-private-CIDRblock[count.index].id
    route_table_id = aws_route_table.rtbprivate.id
}

# Public Subnet
resource "aws_subnet" "subnet-public"{
    count = length(var.vpc-public-CIDRblock)
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.vpc-public-CIDRblock[count.index]
    map_public_ip_on_launch = "true"
    availability_zone = var.availability_zones[count.index]
    tags = {
        Name = "PublicSubnet"
    }
}
#Private Subnet 
resource "aws_subnet" "subnet-private"{
    count = length(var.vpc-private-CIDRblock)
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.vpc-private-CIDRblock[count.index]
    map_private_ip_on_launch = "true"
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "PrivateSubnet"
    }
}

# Creating Security Group and Webserver attached to IGW 

resource "aws_security_group" "web" {
    name = "vpc_web"
    description = "Allow incoming HTTP connections."

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        cidr_blocks = ["var.vpc-public-CIDRblock"]
    }
    egress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["var.vpc-public-CIDRblock"]
    }

    vpc_id = "aws_vpc.vpc.id"

    tags {
        Name = "WebServerSG"
    }
}

resource "aws_instance" "web-1" {
    ami = "lookup(var.amis, var.region"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    key_name = "var.aws_key_name"
    vpc_security_group_ids = ["aws_security_group.web.id"]
    subnet_id = "aws_subnet.us-east-1a-subnet-public.id"
    associate_public_ip_address = true
    source_dest_check = false


    tags {
        Name = "Web Server 1"
    }
}

resource "aws_eip" "web-1" {
    instance = "aws_instance.web-1.id"
    vpc = true
}

# Creating Security Group and Webserver not attached to IGW 

resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connections."

    ingress { # SQL Server
        from_port = 1433
        to_port = 1433
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }
    ingress { # MySQL
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc-public-CIDRblock}"]
        
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc-public-CIDRblock}"]
        
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "aws_vpc.vpc.id"

    tags {
        Name = "DBServerSG"
    }
}

resource "aws_instance" "db-1" {
    ami = "var.amis[var.region]"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    key_name = "var.aws_key_name"
    vpc_security_group_ids = ["aws_security_group.db.id"]
    subnet_id = "aws_subnet.us-east-1a-subnet-private.id"
    source_dest_check = false

    tags {
        Name = "DBServer1"
    }
}