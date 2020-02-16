resource "aws_vpc" "my_vpc" {
    cidr_block = "10.0.0.0/16"
    tags {
        Name = "my_vpc"
    }
}

resource "aws_subnet" "my_subnet_1" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    cidr_block = "10.0.1.0/24"
    availability_zone = "eu-west-1b"
    tags {
        Name = "my_subnet_1"
    }
}

resource "aws_subnet" "my_subnet_2" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-west-1b"
    tags {
        Name = "my_subnet_2"
    }
}

resource "aws_route_table" "my_route_table_1" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.my_gw.id}"
    }
    tags {
        Name = "my_route_table_1"
    }
}

resource "aws_route_table" "my_route_table_2" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.my_nat_gw.id}"
    }
    tags {
        Name = "my_route_table_2"
    }
}

resource "aws_route_table_association" "my_route_subnet_1" {
    subnet_id = "${aws_subnet.my_subnet_1.id}"
    route_table_id = "${aws_route_table.my_route_table_1.id}"
}

resource "aws_route_table_association" "my_route_subnet_2" {
    subnet_id = "${aws_subnet.my_subnet_2.id}"
    route_table_id = "${aws_route_table.my_route_table_2.id}"
}

resource "aws_eip" "my_eip" {
    vpc = true
}

resource "aws_nat_gateway" "my_nat_gw" {
    allocation_id = "${aws_eip.my_eip.id}"
    subnet_id = "${aws_subnet.my_subnet_1.id}"
    tags {
        Name = "my_nat_gw"
    }
}

resource "aws_internet_gateway" "my_gw" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    tags {
        Name = "my_gw"
    }
}

resource "aws_security_group" "my_sec_group" {
    name = "my_sec_group"
    description = "Allow all"
    vpc_id = "${aws_vpc.my_vpc.id}"
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "my_sec_group"
    }
}
