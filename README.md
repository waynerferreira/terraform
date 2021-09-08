# Terraform<h1>
PROJETO ESTUDOS TERRAFORM
###### Este processo instrui desde de a instalaão do terraform, até provisionamento de estruturas na aws.

* Em sua conta da aws, crie um usuário com permissões administrativas, para poder provisionar estruturas no ambiente, com isso salve em um local seguro suas credenciais de acesso AWS.

```
aws_access_key_id
aws_secret_access_key 
```

* Instalação do aws cli e terraform em sua máquina, seja ela windows ou linux, no caso realizei o processo no próprio windows, um pouco mais complicado que no linux.

Deve ser instalado a opção do AWS CLI na máquina e posteriormente o terraform
AWS CLI.
* Ao instalar o mesmo, realizar o login do profile aws para poder construir com o terraform.

Comando: 
```
aws configure --profile user2 
AWS Access Key ID [None]: SUAKEY_ID 
AWS Secret Access Key [None]: SUA_KEY_ACCES 
Default region name [None]: us-east-1 
Default output format [None]: text
```
* Na instalação do terraform via windows, deve ser realizado o download do arquivo do terraform direto do site do mesmo, e para "instalação" deve-se adicionar uma variável de ambiente com a PATH C:\terraform, logicamente deve-se criar este diretório no mesmo local orientado, neste diretório deve ser descompactado o arquivo do download do site do terraform.

* Para verificar se foi instalado corretamente, execute:
```
  terraform -version
```  

* Download da ferramenta VSCODE tanto para windows quando para distribuições linux, 
esta ferramenta facilita o processo.

* No VSCODE realizar a instalação da extensão do terraform.

* Criar seu diretório Terraform, onde vai ficar todos os arquivos de estrutura via terraform, no meu caso criei um diretório em D:\terraform

* Abrir este diretório pelo VSCODE, FILE>OPEN FOLDER>SEUDIRETÓRIO_TERRAFORM
    * Ainda dentro do VSCODE 
No seu diretório do terraform, selecione NEW FILE 
Nomeie o mesmo como main.tf que será o arquivo de construção da estrutura. 

* Estrutura básica para criação de uma buckets3, onde será o backend de nossa estrutura.

No arquivo main.tf, definimos a versão do terraform a ser utilizada.
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
A estrutura abaixo, realiza a criação de um bucket na aws s3, com nome do bucket e a regra de acl, que será sua estrutura de backend alocada na aws.
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
```
terraform plan -out plano
```

```
terraform apply plano
```

Com isso, devmos então iniciar o provisonamento das seguintes estruturas:

* VPC
* Subnet(s)
* ACL
* Security Groups
* Route Table
* Internet Gateway
* Instâcias EC2
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

Em sequência criamos então as nossas subnets, baseadas na nossa VPC ja criada, aonde iremos cria-las de acordo com a faixa de ip da VPC baseado nas nossas devidas demandas:

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
Acima temos utilização de variáveis, onde utilizamos a opção "${var.nomedavariavel}", para que não seja necessário sempre utilizar o id do que foi provisionado, ou realizar alguma referência.

Determinamos também as AZ :

##### Availability Zone ID

use1-az2 E use1-az4

Desta forma podemos criar instâncias com acesso para internet e outras sem acesso para internet de acordo com as rotas projetadas, neste projeto não foi escolhido desta forma, mas é simples o detach para bloqueio de saída de internet das instâncias.

Exemplo com utilização de variáveis:

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
Acima criamos a nossa route table, no próximo passo, é realizado a criação de rotas e associação as subnets.

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

rt-teste com vínculo as duas subnets (pois a intenção seria simular somente instâncias com faixa de ips diferentes por ser ambiente de testes e com isso ambas com saída para internet, fazendo estrutura de master-worker para k8s / docker swarm)

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
Acima temos a criação de uma regra de ACL, e associamos a mesma a nossa VPC e a uma subnet específica, dando permissão de entrada e saída para internet.

>Tome cuidados com as suas permissões de acesso ao seu ambiente, pois neste caso temos um ambiente de teste, e não de produção.

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

Exemplo acima de liberação da porta 22 para acesso via ssh nas instâncias, e regra de saída da mesma para internet.

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

Criada instâncias t2.micro para montar um ambiente de testes com Docker e Docker swarm.

Neste exemplo acima, temos a opção do count, para o mesmo provisionar o número de instâncias setada sobre ele, associamos subnet, security group, e chave de acesso a aws.

## Processo de vínculo com Github e Terraform Cloud <h1>

Realizado Vínculo da estrutura do código Terraform no vscode máquina local, vinculado o mesmo no repositório Terraform na minha conta no github.

Feito push de todos os arquivos e vínculos com Github, Foi realizado o processo de conexão da minha estrutura GITHUB/TERRAFORM com a Ferramenta Terraform cloud.

Em minha conta do terraform, acessando pelo https://app.terraform.io/.

* Realiza a criação de uma organização, e vincula ao seu repositório, no meu caso Github/terraform.

* Ao criar a organização no terraform cloud app, é necessário setar as variáveis de ambiente de acesso ao backend de sua estrutura no Terraform, sendo AWS neste caso e selecionado meu repo github.

Com isso foram interligados as seguintes ferramentas:

    * Vscode com aws cli / terraform

    * Vscode com estrutura terraform ao github repositório de nome Terraform

    * Github repositório Terraform ao TERRAFORM CLOUD APP 

Desta forma podemos atualizar a estrutura, onde ela é analisada pelo APP TERRAFORM CLOUD após commit/push no github.

Assim fica mais fácil visualizar os processos que ocorrem ao ser realizado plan e apply da estrutura, pois o _TERRAFORM CLOUD APP_ tem um dashboard que ajuda bastante (lembrando que é uma opção de usabilidade ).

### A ser feito via terraform
Criado estrutura de Load Balancer e target groups para acesso as portas específicas das aplicações. 

Load balancer feito diretamente no dashboard aws (não tive tempo para replicar na estrutura), mas o processo é relativamente simples como mostrado no exemplo abaixo. 

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

Com as estruturas criadas e realizado os determinados vínculos, realizamos acesso às instâncias.

Feita instalação docker, docker swarm, docker compose, criação de estruturas com yml.

E os acessos nas aplicações são realizados via dns:porta DNS do load Balancer porta da aplicação com mesma porta Target Group.

Projetos futuros e com maior tempo, será utilizado Ferramenta Ansible para automatização de mais processos nas aplicações e vínculo com GITHUB ACTION, assim como feito na Estrutura do repositório do DESAFIO.


