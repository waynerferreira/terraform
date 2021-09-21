resource "aws_instance" "web" {
   count = 0
    ami = "ami-07d02ee1eeb0c996c"
    instance_type = "t2.micro"

   /*dynamic "ebs_block_device"{
        for_each = "${var.blocks}" 
        content {
            device_name = ebs_block_device.value["device_name"]
            volume_size = ebs_block_device.value["volume_size"]
            volume_type = ebs_block_device.value["volume_type"]
        }
    }*/


    tags = {
       # Name = "k8s"
        Name = "k8s${count.index}"
    }
    subnet_id = "${var.subnet-testeA}"
    vpc_security_group_ids = ["${aws_security_group.sg_teste.id}"]
    key_name = "${var.key_name}"
}




resource "aws_instance" "k8stesteb" {
    count = 0
    ami = "ami-07d02ee1eeb0c996c"
    instance_type = "t2.micro"
    tags = {
        Name = "k8stesteb${count.index}"
    }
    subnet_id = "${var.subnet-testeB}"
    vpc_security_group_ids = ["${aws_security_group.sg_teste.id}"]
    key_name = "${var.key_name}"
}

resource "aws_instance" "master" {
    count = "${var.servers}"
    ami = "ami-07d02ee1eeb0c996c"
    instance_type = "t2.micro"
    tags = {
        Name = "master${count.index}"
    }
    subnet_id = "${var.subnet-testeA}"
    vpc_security_group_ids = ["${aws_security_group.sg_teste.id}"]
    key_name = "${var.key_name}"
}

resource "aws_instance" "worker" {
    count = "${var.servers}"
    ami = "ami-07d02ee1eeb0c996c"
    instance_type = "t2.micro"
    tags = {
        Name = "worker${count.index}"
    }
    subnet_id = "${var.subnet-testeB}"
    vpc_security_group_ids = ["${aws_security_group.sg_teste.id}"]
    key_name = "${var.key_name}"
}


/*resource "aws_instance" "novamaster" {
    count = 1
    ami = "ami-07d02ee1eeb0c996c"
    instance_type = "t2.medium"
    tags = {
        Name = "novamaster${count.index}"
    }
    subnet_id = "${var.subnet-testeA}"
    vpc_security_group_ids = ["${aws_security_group.sg_teste.id}"]
    key_name = "${var.key_name}"
}
*/