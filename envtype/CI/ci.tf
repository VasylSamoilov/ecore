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
      from_port = 5051
      to_port = 5051
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
      from_port = 1194
      to_port = 1194
      protocol = "udp"
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
	mesos_hostname = "${aws_elb.mesos-master.dns_name}"
    }
}

resource "template_file" "mesos_slave_userdata" {
    template = "${file("../../instancetype/slave/user-data.tpl")}"

    vars {
        etcd_cluster_token = "${var.token}"
	mesos_hostname = "${aws_elb.mesos-master.dns_name}"
    }

}

resource "template_file" "mesos_slave_public_userdata" {
    template = "${file("../../instancetype/slave_public/user-data.tpl")}"

    vars {
        etcd_cluster_token = "${var.token}"
        default_role = "slave_public"
	mesos_hostname = "${aws_elb.mesos-master.dns_name}"
    }

}

resource "template_file" "vpnserver_userdata" {
    template = "${file("../../instancetype/vpnserver/user-data.tpl")}"

    vars {
        etcd_cluster_token = "${var.token}"
    }

}

resource "aws_instance" "vpnserver" {
    ami = "${var.mesos_all_in_one_ami}"
    instance_type = "t2.nano"
    key_name = "${aws_key_pair.deployer.key_name}"
    security_groups = ["${aws_security_group.mesos_master.id}"]
    subnet_id = "${aws_subnet.sub_1.id}"
    user_data = "${template_file.vpnserver_userdata.rendered}"
    associate_public_ip_address = "true"
    provisioner "remote-exec" {
    connection {
        timeout = "15m"
        user = "core"
        private_key = "${var.ssh_priv_key}"
    }
        inline = [
	"until docker port openvpnd; do sleep 5; done",
        "docker run --volumes-from openvpn --rm nixlike/openvpn easyrsa build-client-full ADMIN nopass",
        "docker run --volumes-from openvpn --rm nixlike/openvpn ovpn_getclient ADMIN > ADMIN.ovpn"
        ]
    }
    provisioner "local-exec" {
    connection {
        timeout = "15m"
        user = "core"
        private_key = "${var.ssh_priv_key}"
    }
        command = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${var.ssh_priv_key} core@${aws_instance.vpnserver.public_ip}:ADMIN* ${var.admin_download_folder}"
    }
    tags {
        Name = "VpnServer"
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
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_launch_configuration" "mesos_slave" {
    name_prefix = "mesos_slave-"
    image_id = "${var.mesos_all_in_one_ami}"
    instance_type = "${var.mesos_all_in_one_nstance_type}"
    key_name = "${aws_key_pair.deployer.key_name}"
    user_data = "${template_file.mesos_slave_userdata.rendered}"
    security_groups = ["${aws_security_group.mesos_master.id}"]
    associate_public_ip_address = "true"
}

resource "aws_autoscaling_group" "mesos_slave" {
    launch_configuration = "${aws_launch_configuration.mesos_slave.name}"
    vpc_zone_identifier = ["${aws_subnet.sub_1.id}"]
    max_size = 1
    min_size = 1
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_launch_configuration" "mesos_slave_public" {
    name_prefix = "mesos_slave_public-"
    image_id = "${var.mesos_all_in_one_ami}"
    instance_type = "${var.mesos_all_in_one_nstance_type}"
    key_name = "${aws_key_pair.deployer.key_name}"
    user_data = "${template_file.mesos_slave_public_userdata.rendered}"
    associate_public_ip_address = "true"
    security_groups = ["${aws_security_group.mesos_master.id}"]
}

resource "aws_autoscaling_group" "mesos_slave_public" {
    launch_configuration = "${aws_launch_configuration.mesos_slave_public.name}"
    vpc_zone_identifier = ["${aws_subnet.sub_1.id}"]
    max_size = 1
    min_size = 1
    lifecycle {
      create_before_destroy = true
    }
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
    instance_port = 5051
    instance_protocol = "http"
    lb_port = 5051
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


output "mesos-master-lb" {
    value = "${aws_elb.mesos-master.dns_name}"
}
output "vpnserver-public_ip" {
    value = "${aws_instance.vpnserver.public_ip}"
}
