# Terraform<h1>
PROJETO ESTUDOS TERRAFORM

* Intalação do aws cli e terraform em sua maquina, seja ela windows ou linux, no caso na facil realizei o processo no próprio windows, um pouco mais complicado que no linux aparentemente.
Deve ser instalado a opçao do AWS CLI na maquina e posteriormente o terraform
AWS CLI.
* Ao instalar o mesmo realizar o login do profile aws para poder construir com o terraform
comando: 
```
aws configure --profile user2 
AWS Access Key ID [None]: SUAKEY_ID 
AWS Secret Access Key [None]: SUA_KEY_ACCES 
Default region name [None]: us-east-1 
Default output format [None]: text
```
* Na instalação do terraform via windows, deve ser realizado o download do arquivo do terraform direto do site do mesmo, e para "instalação" deve-se adicionar uma variavel de ambiente com a PATH C:\terraform, logicamente deve-se criar este diretório no mesmo local orientado, neste diretório deve ser descompactado o arquivo do download do site do terraform.

* Para verificar se foi instalado corretamente, execute:
```
  terraform -version
```  

* Download da ferramenta VSCODE tanto para windows quando para distribuições linux com tela gráfica
esta ferramenta facilita o processo.

* No VSCODE realizar a instalação da extensão do terraform

* Criar seu diretório Terraform, onde vai ficar todos os arquivos de estrutura via terraform, no meu caso criei um diretório em D:\terraform

* Abrir este diretório pelo VSCODE, FILE>OPEN FOLDER>SEUDIRETÓRIO_TERRAFORM
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

# Estrutura terraform <h1>

* VPC:

Temos aqui instruções de provisionamento de uma VPC na aws, seguindo uma faixa de ip /16, setando a mesma como Default e nomeando utilizando o termo "tags".

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

* Subnets A e B:

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

Determinamos também as AZ :

##### Availability Zone ID

use1-az2 E use1-az4

Desta forma podemos criar instâncias com acesso para internet e outras sem acesso para internet de acordo com as rotas projetadas, neste projeto não foi escolhido desta forma, mas é simples o detach para bloqueio de saida de internet das instâncias.

Exemplo com utilização de variaveis:

```
variable "vpcteste" {
    default = "vpc-05e4basd3a4s5nc3e6"
}
```
* Route table:

```
resource "aws_route_table" "rt-teste" {
  vpc_id = "${var.vpcteste}"
  tags = {
    Name = "rt-teste"
  }
}
```
Acima criamos nossa route table, no próximo passo, é realizado a criação de rotas e associação as subnets.

Criando rotas:

```
resource "aws_route" "rotas-teste" {
  route_table_id = "${aws_route_table.rt-teste.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw-teste.id}"

  depends_on = [aws_route_table.rt-teste]
}
```

Associando route table em nossa sub-net:

```
resource "aws_route_table_association" "rt-subnet-testeA" {
  subnet_id = "${var.subnet-testeA}"
  route_table_id = "rtb-02711fa49579500ca"

 }
resource "aws_route_table_association" "rt-subnet-testeB" {
  subnet_id = "${var.subnet-testeB}"
  route_table_id = "rtb-02711fa49579500ca"

 }
```

rt-teste com vínculo as duas subnets (pois a intenção serira simular somente instâncias com faixa de ips diferentes por ser ambiente de testes e com isso ambas com saida para internet, fazendo estrutura de master-worker para k8s / docker swarm)

* ACL

```
resource "aws_network_acl" "acl_teste" {
  vpc_id = "${var.vpcteste}"
  subnet_ids = [aws_subnet.subnet-testeA.id]
    tags = {
    name = "acl_teste"
  }
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
```
Acima temos a criação de uma regra de ACL, e associamos a mesma a nossa VPC e a uma subnet específica, dando permissão de entrada e saida para internet.

>Tome cuidados com suas permissões de acesso ao seu ambiente, pois neste caso temos um ambiente de teste, e não de produção.

* Internet Gateway
```
resource "aws_internet_gateway" "igw-teste" {
    vpc_id = "${var.vpcteste}"

    tags = {
      Name = "igw-teste"
    }
}
```

 Attached na VPC para ter saida a internet

* Security Groups
```
resource "aws_security_group" "sg_teste" {
  vpc_id = "${var.vpcteste}"

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
```

Regras de ingress e egress das instâncias e seus devidos vínculos.

Lembrando que este é um ambiente de testes.

Exemplo acima de liberação da porta 22 para acesso via ssh nas instâncias, e regra de saida da mesma para internet.

* EC2

```
resource "aws_instance" "web" {
   count = 6
    ami = "ami-07d02ee1eeb0c996c"
    instance_type = "t2.micro"
    tags = {
        Name = "docker${count.index}"
    }
    subnet_id = "${var.subnet-testeA}"
    vpc_security_group_ids = ["${aws_security_group.sg_teste.id}"]
    key_name = "${var.key_name}"
}

```

Criado instâncias t2.micro para criação de um ambiente de testes com Docker e Docker swarm.

Neste exemplo acima, temos a opção do count, para o mesmo provisionar o número de instancias setada sobre ele, associamos subnet, security group, e chave de acesso a aws.

## Processo de vínculo com Github e Terraform Cloud <h1>

Realizado Vínculo da estrutura do códico Terraform no vscode maquina local, vinculado o mesmo no repositório Terraform em minha conta no github.

Feito push de todos arquivos e vínculos com Github, Foi realizado o processo de conexão da minha estrutura GITHUB/TERRAFORM com a Ferramenta Terraform cloud.

Em minha conta do terraform, acessando pelo https://app.terraform.io/.

* Realiza a criação de uma organização, e vincula ao seu reposiório, no meu caso Github/terraform.

* Ao criar a organização no terraform cloud app, é necessário setar as variaveis de ambiente de acesso ao backend de sua estrutura no Terraform, sendo AWS neste caso e selecionado meu repo github.

Com isso foram interligados as seguintes ferramentas:

    * Vscode com aws cli / terraform

    * Vscode com estrutura terraform ao github repositório de nome Terraform

    * Github repositório Terraform ao TERRAFORM CLOUD APP 

Desta forma podemos atualizar a estrutua, onde ela é analisada pelo APP TERRAFORM CLOUD após commit/push no github.

Assim fica mais fácil visualizar os processos que ocorrem ao ser realizado plan e apply da estrutura, pois o _TERRAFORM CLOUD APP_ tem um dashboard que ajuda bastante (lembrando que é uma opção de usabilidade ).

### A ser montado via terraform
Criado estrutura de Load Balancer e target groups para acesso a a portas específicas das aplicações 

Load balancer feito diretamente no dashboard aws (não tive tempo para replicar na esturura), mas o processo é relativamente simples como mostrado no exemplo abaixo. 

Tudo na documentação da Hashicorp/aws.

Estrutura similar abaixo:

Application Load Balancer

```
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "test-lb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}
```
E realizar os devidos vínculos ao Target Group, que neste caso, seria seguindo o modelo abaixo:

```
resource "aws_lb_target_group" "test" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

```

Com as estruturas criadas e realizado os determinádos vínculos, realizamos acesso as instâncias.

Feito instalação docker, docker swarm, docker compose, criação de estruturas com yml.

E os acessos nas aplicações são realizado via dns:porta DNS do load Balancer porta da aplicação com mesma porta Target Group.

Projetos futuros e com maior tempo, será utilizado Ferramenta Ansible para automatização de mais processos nas aplicações e vínculo com GITHUB ACTION, assim como feito na Estrutura do repositório do DESAFIO.


