
resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "all_worker_mgmt_ingress" {
  description       = "allow inbound traffic from eks"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  security_group_id = aws_security_group.all_worker_mgmt.id
  type              = "ingress"
  cidr_blocks = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

resource "aws_security_group_rule" "all_worker_mgmt_egress" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.all_worker_mgmt.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "null_resource" "delete_security_groups" {
  triggers = {
    vpc_id = module.vpc.name
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ec2 describe-security-groups --filters "Name=vpc-id,Values=${self.triggers.vpc_id}" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text | xargs -n 1 aws ec2 delete-security-group --group-id 
    EOT
  }
}