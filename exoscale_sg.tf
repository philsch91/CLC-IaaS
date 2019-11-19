resource "exoscale_security_group" "security-group-1" {
  name = "philipp"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = "${exoscale_security_group.security-group-1.id}"
  type = "INGRESS"
  protocol = "TCP"
  cidr = "0.0.0.0/0"
  start_port = 80
  end_port = 80
}

resource "exoscale_security_group_rule" "ssh" {
  security_group_id = "${exoscale_security_group.security-group-1.id}"
  type = "INGRESS"
  protocol = "TCP"
  cidr = "1.2.3.4/32"
  start_port = 22
  end_port = 22
}

