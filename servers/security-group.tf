resource "aws_security_group_rule" "sg_teste" {
  vpc_id = "${var.vpcteste}"
  security_group_id = "sg-0c3d1c6d80cbc56d5"
  ingress {
    from_port = 0
    to_port   = 65535
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 0
    to_port   = 0
    protocol = "All"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 80
    to_port   = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = "${var.cdirs_acesso_remoto}"
  }
    egress {
    from_port = 0
    to_port   = 0
    protocol = "All"
    cidr_blocks = ["0.0.0.0/0"]
  }
    tags = {
        Name = "sg_teste"
    }
 }