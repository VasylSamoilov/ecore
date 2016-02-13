provider "aws" {
    region = "${var.core_region}"
}

resource "aws_key_pair" "deployer" {
  key_name = "${var.deployer_key_name}"
  public_key = "${var.deployer_key_pub}"
}

resource "aws_vpc" "mesos" {
    cidr_block = "${var.core_vpc_network}"

    tags {
        Name = "mesos"
    }
}

resource "aws_subnet" "subnet_1" {
    vpc_id = "${aws_vpc.mesos.id}"
    cidr_block = "${var.core_vpc_subnet_1}"

    tags {
        Name = "Main"
    }
}

resource "aws_instance" "mesos_all_in_one" {
    ami = "${var.mesos_all_in_one_ami}"
    instance_type = "${var.mesos_all_in_one_nstance_type}"
    key_name = "${aws_key_pair.deployer.key_name}"
    subnet_id= "${aws_subnet.subnet_1.id}"
}
