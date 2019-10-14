data "aws_instances" "k3s_master" {
  depends_on = ["aws_autoscaling_group.asg_master"]

  instance_tags = {
    Name = "k3s-master"
  }
}

data "aws_instances" "k3s_nodes" {
  depends_on = ["aws_autoscaling_group.asg_node"]

  instance_tags = {
    Name = "k3s-node"
  }
}

resource "aws_route53_record" "drone-record-set" {
  zone_id = "${var.hosted_zone_id}"
  name    = "drone.${var.group}-${var.env}.${var.domain_url}"
  type    = "A"
  ttl     = "300"
  records = ["${data.aws_instances.k3s_master_0_private_ip.public_ips[0]}"]
}

output "k3s_master_0_private_ip" {
  value = "${data.aws_instances.k3s_master.private_ips[0]}"
}

output "k3s_master_0_public_ip" {
  value = "${data.aws_instances.k3s_master.public_ips[0]}"
}

output "k3s_node_0_private_ip" {
  value = "${data.aws_instances.k3s_nodes.private_ips[0]}"
}

output "k3s_node_0_public_ip" {
  value = "${data.aws_instances.k3s_nodes.public_ips[0]}"
}

output "k3s_bastion_0_public_ip" {
  value = "${aws_instance.k3s_bastion.public_ip}"
}

output "k3s_bastion_0_private_ip" {
  value = "${aws_instance.k3s_bastion.private_ip}"
}

output "ansible_inventory" {
  value = <<EOF
[all:vars]
ansible_ssh_extra_args=-F ./ssh.cfg -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -F ./ssh.cfg ${aws_instance.k3s_bastion.public_ip}"

[bastions:vars]
ansible_ssh_extra_args=-F ./ssh.cfg

[masters]
master-0 ansible_host=${data.aws_instances.k3s_master.private_ips[0]}

[nodes]
node-0 ansible_host=${data.aws_instances.k3s_nodes.private_ips[0]}

[bastions]
bastion-0 ansible_host=${aws_instance.k3s_bastion.public_ip}

[k3s-cluster:children]
masters
nodes
EOF
}
