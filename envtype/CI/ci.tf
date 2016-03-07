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

resource "aws_internet_gateway" "gw" {
    vpc_id = "${aws_vpc.mesos.id}"

    tags {
        Name = "meosos vpc internet GW"
    }
}

resource "aws_security_group" "mesos_master" {
  name = "mesos_master"
  description = "Allows all needed for mesos masters functioning"
  vpc_id = "${aws_vpc.mesos.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.admin_location}"]
  }
  ingress {
      from_port = 5050
      to_port = 5050
      protocol = "tcp"
      cidr_blocks = ["${var.admin_location}"]
  }
  ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["${var.admin_location}"]
  }
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "sub_1" {
    vpc_id = "${aws_vpc.mesos.id}"
    cidr_block = "${var.core_vpc_sub_1}"

    tags {
        Name = "Main"
    }
}

resource "aws_route_table" "r_pub_sub" {
    vpc_id = "${aws_vpc.mesos.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.gw.id}"
    }

    tags {
        Name = "main"
    }
}

resource "aws_route_table_association" "pub_sub_route_a" {
    subnet_id = "${aws_subnet.sub_1.id}"
    route_table_id = "${aws_route_table.r_pub_sub.id}"
}

resource "template_file" "mesos_master_userdata" {
    template = "${file("../../instancetype/master/user-data.tpl")}"

    vars {
        etcd_cluster_token = "${var.token}"
        default_role = "slave_public"
    }
}

resource "template_file" "mesos_slave_userdata" {
    template = "${file("../../instancetype/slave/user-data.tpl")}"

    vars {
        etcd_cluster_token = "${var.token}"
    }

}

resource "aws_launch_configuration" "mesos_master" {
    name_prefix = "mesos_master-"
    image_id = "${var.mesos_all_in_one_ami}"
    instance_type = "${var.mesos_all_in_one_nstance_type}"
    key_name = "${aws_key_pair.deployer.key_name}"
    user_data = "${template_file.mesos_master_userdata.rendered}"
    associate_public_ip_address = "true"
    security_groups = ["${aws_security_group.mesos_master.id}"]
}

resource "aws_autoscaling_group" "mesos_master" {
    launch_configuration = "${aws_launch_configuration.mesos_master.name}"
    vpc_zone_identifier = ["${aws_subnet.sub_1.id}"]
    max_size = 1
    min_size = 1
    load_balancers = ["${aws_elb.mesos-master.name}"]
}

resource "aws_elb" "mesos-master" {
  subnets = ["${aws_subnet.sub_1.id}"]
  security_groups = ["${aws_security_group.mesos_master.id}"]

  listener {
    instance_port = 5050
    instance_protocol = "http"
    lb_port = 5050
    lb_protocol = "http"
  }

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 8080
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:5050/"
    interval = 30
  }
  cross_zone_load_balancing = "true"

  tags {
    Name = "mesos-master-lb"
  }
}

resource "aws_instance" "mesos_slave" {
    ami = "${var.mesos_all_in_one_ami}"
    vpc_security_group_ids = ["${aws_security_group.mesos_master.id}"]
    instance_type = "${var.mesos_all_in_one_nstance_type}"
    key_name = "${aws_key_pair.deployer.key_name}"
    subnet_id= "${aws_subnet.sub_1.id}"
    associate_public_ip_address = "true"
    user_data = "${template_file.mesos_slave_userdata.rendered}"
    depends_on = ["aws_autoscaling_group.mesos_master"]
    provisioner "remote-exec" {
    inline = [
     "while [ ! -f /tmp/signal ]; do sleep 2; done"
      ]
    }
    connection {
        user = "core"
        private_key = "${var.ssh_priv_key}"
    }
    tags {
        Name = "Mesos slave"
    }
}

output "mesos-master-lb" {
    value = "${aws_elb.mesos-master.dns_name}"
}

output "slave_public_address" {
    value = "${aws_instance.mesos_slave.public_ip}"
}
