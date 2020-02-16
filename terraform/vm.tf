resource "aws_instance" "public_instance" {
    ami = "ami-078603b469de54ad7"
    instance_type = "a1.medium"
    key_name = "${aws_key_pair.public_key.key_name}"
    associate_public_ip_address = true
    subnet_id = "${aws_subnet.my_subnet_1.id}"
    vpc_security_group_ids = ["${aws_security_group.my_sec_group.id}"]


    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file(local_file.private_key.filename)}"
        host = "${self.public_ip}"
    }

    provisioner "file" {
        source = "${local_file.private_key.filename}"
        destination = "~/${basename(local_file.private_key.filename)}"
    }

    provisioner "file" {
        content = "${join("\n", aws_instance.private_instance.*.private_ip)}"
        destination = "~/ansible-hosts"
    }

    provisioner "file" {
        content = <<EOF
[defaults]
host_key_checking = False
EOF
        destination = "~/.ansible.cfg"
    }

    provisioner "remote-exec" {
        inline = [
            "chmod 400 ~/${basename(local_file.private_key.filename)}",
            "sudo apt update",
            "sudo apt install --yes software-properties-common git",
            "sudo apt-add-repository --yes --update ppa:ansible/ansible",
            "sudo apt update",
            "sudo apt install --yes ansible",
            "git clone https://github.com/schipiga/infro.git",
            "ansible-playbook -i ansible-hosts --private-key key.pem infro/ansible/my-playbook.yaml"
        ]
    }
}

resource "aws_instance" "private_instance" {
    count = 2
    ami = "ami-078603b469de54ad7"
    instance_type = "a1.medium"
    key_name = "${aws_key_pair.public_key.key_name}"
    subnet_id = "${aws_subnet.my_subnet_2.id}"
    vpc_security_group_ids = ["${aws_security_group.my_sec_group.id}"]
}
