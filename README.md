# Terraform<h1>
PROJETO ESTUDOS TERRAFORM

* Intalação do aws cli e terraform em sua maquina, seja ela windows ou linux, no caso na facil realizei o processo no próprio windows, um pouco mais complicado que no linux aparentemente.
Deve ser instalado a opçao do AWS CLI na maquina e posteriormente o terraform
AWS CLI
* Ao instalar o mesmo realizar o login do profile aws para poder construir com o terraform
comando: aws configure --profile user2 
AWS Access Key ID [None]: SUAKEY_ID 
AWS Secret Access Key [None]: SUA_KEY_ACCES 
Default region name [None]: us-east-1 
Default output format [None]: text

* Na instalação do terraform via windows, deve ser realizado o download do arquivo do terraform direto do site do mesmo, e para "instalação" deve-se adicionar uma variavel de ambiente com a PATH C:\terraform, logicamente deve-se criar este diretório no mesmo local orientado , neste diretório deve ser descompactado o arquivo do download do site do terraform.

* Para verificar se foi instalado corretamente, execute:
```
  terraform -version
```  

* Download da ferramenta VSCODE tanto para windows quando para distribuições linux com tela gráfica
esta ferramenta facilita o processo.

* No VSCODE realizar a instalação da extensão do terraform

* Criar seu diretório Terraform, onde vai ficar todos os arquivos de estrutura via terraform, no meu caso criei um diretório em D:\terraform

* Abrir este diretório pelo VSCODE , FILE>OPEN FOLDER>SEUDIRETÓRIO_TERRAFORM
    * Ainda dentro do VSCODE 
No seu diretório do terraform, selecione NEW FILE 
Nomeie o mesmo como main.tf que será o arquivo de construção da estrutura. 

* Estrutura basica para criação de uma buckets3 

Definimos a versão do terraform a ser utilizada
```
terraform {
    required_version = ">= 0.12.25"      
}
```
A instrução abaixo, indica o provider que irá trabalhar, sendo aws, gcloud e demais, e a região do AZ)
```
provider "aws" {                                      
    region = "us-east-1"
}
```
O comando abaixo, realiza a criação de um bucket na aws s3 com nome do bucket e a regra de acl, onde será basicamente sua estrutura de backend alocada na aws.
```
resource "aws_s3_bucket" "terraform-teste-wayner2" {
    bucket = "waynerferreiraaws2"
    acl = "private"
}
```

* No terminal do vscode, execute:
```
terraform init
```

Com isso devmos então iniciar o provisonamento das seguintes estruturas:

* VPC
* Subnet(s)
* ACL
* Security Groups
* Route Table
* Internet Gateway

Estrutura de VPC:

Temos aqui instruções de provisionamento de uma VPC na aws, seguindo uma faixa de ip /16 , setando a mesma como Default e nomeando utilizando o termo "tags".

```
resource "aws_vpc" "vpcteste" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpcteste"
  }
}
```

Como sequencia criamos então nossas subnets, baseadas na nossa VPC ja criada, onde iremos cria-las de acordo com a faixa de ip da VPC basedo em nossas devidas demandas:

Subnets A e B:

```
resource "aws_subnet" "subnet-testeA" {
  vpc_id     = "${var.vpcteste}"
  cidr_block = "10.0.1.0/24"
  availability_zone_id = "use1-az2"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-testeA"
  }
}
resource "aws_subnet" "subnet-testeB" {
  vpc_id     = "${var.vpcteste}"
  cidr_block = "10.0.2.0/24"
  availability_zone_id = "use1-az4"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "subnet-testeB"
  }
}
```
Acima temos utilização de variaveis, onde utilizamos a opção "${var.nomedavariavel}", para que não seja necessário sempre utilizar o id do que foi provisionado, ou realizar alguma referência.

Exemplo com utilização de variaveis:

```
variable "vpcteste" {
    default = "vpc-05e4basd3a4s5nc3e6"
}
```