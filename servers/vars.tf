variable "amis" {
    #type = map
    default = {
        "us-east-1" = "ami-08b2293fdd2deba2a"
        "us-east-2" = "ami-089fe97bc00bff7cc"
    }
}

variable "cdirs_acesso_remoto" {
    default = ["0.0.0.0/0"]
}
variable "vpcteste" {
    default = "vpc-05e4bfbf22ea3c3e6"
}
variable "subnet-testeA"{
    default = "subnet-099f492bd64c488b8"
}
variable "subnet-testeB"{
    default = "subnet-0df6a0b946c26a8e1"
}
variable "acl_teste"{
    default = "acl-0b8cc6c418522f858"
}
variable "sg_teste" {
    #type = map
#   description = "sg-0714a8294df4cb3ad"
    default = {
    aws_security_group = "sg-0c3d1c6d80cbc56d5"
    }
}
variable "igw-teste" {
    default = "igw-0101990dce7045f2c"
}

variable "rt-teste" {
    default = "rtb-03cbfc4703895832c"
  
}
variable "key_name" {
    default = "chaveaws-local"
}

variable "servers" {

}
/*
variable "blocks" {
    type = list (object({
        device_name = string
        volume_size = string
        volume_type = string
    }))
    description = "List of EBS block"
}
*/
/*
variable "name_instances" {
  #  type = string
    default = "k8s"
    description = "Nome das instancias EC2"
}
/*
variable "instance_type"{
    type = list (string)
    default = ["t2.micro","t3.medium"] 
    description = "The list of instance type"
}
*/