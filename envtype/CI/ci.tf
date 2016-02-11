provider "aws" {
    region = "eu-west-1"
}

resource "aws_key_pair" "deployer" {
  key_name = "nixlike" 
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC12JbIiEYD/MB0tP+2iieiBbxU2GYrMJLHPwSEmB3FFBn2NruDM4Aghq0V7VCyEDkNeiaFqhYZy/XrCS9l6HUcpOmFTciRJ3g7kXMqxprCLLktfU1VL6IMtYHn0BSGTQMjtqLDkMnnjEWKneCQJu/YmUDyxnVo6+fcgbWA6iHmkJCwzHPYMtiVjfBubaDGR1HOPm/OlEjXEdLTQnCjHBuxEVWM9ZIrUoUZAzObKvmWdxcW2O9qSa9vrtTFql80a1aH39INBjh6icR2nDx18BXzlbuZiDuHI+LOKWEgEaVKkNmeIdLDBjUpjlOAWUaBTF9XikcTR+0bd5LH1xLWlBdH"
}

resource "aws_instance" "mesos_all_in_one" {
    ami = "ami-e0f34093"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
}
