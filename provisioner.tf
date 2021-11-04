# Generate host inventory file for Ansible
resource "null_resource" "kafkanode_host_file_run" {

  depends_on = [google_compute_instance.kafka-node]

  provisioner "local-exec" {
    command =  "echo \"[kafka_broker]\" > /tmp/inventory_kafka.txt"
  }

  provisioner "local-exec" {
    command = "echo ${element(google_compute_instance.kafka-node.*.name, count.index)} ansible_ssh_host=${element(google_compute_instance.kafka-node.*.network_interface.0.network_ip, count.index)} ansible_ssh_port=22 ansible_ssh_user=${var.kafka_user} broker_id=${count.index} >> /tmp/inventory_kafka.txt&"

  }
  count = "${var.instance_count}"
}

resource "null_resource" "zookeeper_host_file_run" {

  depends_on = [google_compute_instance.kafka-node]

  provisioner "local-exec" {
    command =  "echo \"[zookeeper]\" > /tmp/inventory_zookeeper.txt"
  }

  provisioner "local-exec" {
    command = "echo ${element(google_compute_instance.kafka-node.*.name, count.index)} ansible_ssh_host=${element(google_compute_instance.kafka-node.*.network_interface.0.network_ip, count.index)} ansible_ssh_port=22 ansible_ssh_user=${var.kafka_user} >> /tmp/inventory_zookeeper.txt&"

  }
  count = "${var.instance_count}"
}

resource "null_resource" "combine_inventory" {
  depends_on = [null_resource.kafkanode_host_file_run, null_resource.zookeeper_host_file_run]
  provisioner "local-exec" {
    command =  "cat /tmp/inventory_kafka.txt /tmp/inventory_zookeeper.txt > /tmp/inventory.txt && rm /tmp/inventory_kafka.txt /tmp/inventory_zookeeper.txt"
  }
}

# Bastion initialization
resource "null_resource" "broker_initialization" {

  depends_on = [google_compute_instance.kafka-node, null_resource.kafkanode_host_file_run]

  connection {
        agent = true
        timeout = "2m"
        host = "${google_compute_address.bastion_public_ip.address}"
        user = "${var.kafka_user}"
        private_key = "${file(var.kafka_privkey)}"
#        bastion_host = "${google_compute_address.bastion_public_ip.address}"
#        bastion_user = "${var.kafka_user}"
#        bastion_private_key = "${file(var.kafka_privkey)}"
   }

  provisioner "file" {
    source      = "/tmp/inventory.txt"
    destination = "/tmp/inventory.txt"
  }

   provisioner "file" {
    source      = "${var.kafka_privkey}"
    destination = "~/.ssh/ssh_key"
  }

  provisioner "remote-exec" {
    inline = [
    "sudo yum install epel-release -y",
    "sudo yum install ansible-2.4.2.0-2.el7 python-pip -y",
    "sudo yum install git gcc -y",
    "sudo echo -e 'StrictHostKeyChecking no\n' >> ~/.ssh/config; sudo chmod 600 ~/.ssh/config",
    "sudo chmod 600 ~/.ssh/ssh_key",
#    "git clone https://github.com/parducci/ansible-exercise.git ansible-exercise",
#    "cp /tmp/inventory.txt ansible-exercise/hosts"
#    "sleep 10 && cd ansible-exercise && ansible-playbook -vvv -i hosts --private-key ~/.ssh/ssh_key site.yml",
    ]
  }

}
