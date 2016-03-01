variable "deployer_key_name" {
    type = "string"
    default = "nixlike"
}

variable "deployer_key_pub" {
    type = "string"
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC12JbIiEYD/MB0tP+2iieiBbxU2GYrMJLHPwSEmB3FFBn2NruDM4Aghq0V7VCyEDkNeiaFqhYZy/XrCS9l6HUcpOmFTciRJ3g7kXMqxprCLLktfU1VL6IMtYHn0BSGTQMjtqLDkMnnjEWKneCQJu/YmUDyxnVo6+fcgbWA6iHmkJCwzHPYMtiVjfBubaDGR1HOPm/OlEjXEdLTQnCjHBuxEVWM9ZIrUoUZAzObKvmWdxcW2O9qSa9vrtTFql80a1aH39INBjh6icR2nDx18BXzlbuZiDuHI+LOKWEgEaVKkNmeIdLDBjUpjlOAWUaBTF9XikcTR+0bd5LH1xLWlBdH"
}

variable "core_region" {
    type = "string"
    default = "eu-west-1"
}

variable "mesos_all_in_one_ami" {
    type = "string"
    default = "ami-a10ab5d2"
}

variable "mesos_all_in_one_nstance_type" {
    type = "string"
    default = "t2.small"
}

variable "core_vpc_network" {
    type = "string"
    default = "10.100.0.0/16"
}

variable "core_vpc_sub_1" {
    type = "string"
    default = "10.100.1.0/24"
}

variable "admin_location" {
    type = "string"
    default = "0.0.0.0/0"
}

variable "ssh_priv_key" {
    type = "string"
    default = "/Users/nixlike/.ssh/id_rsa_ACM.pem"
}


