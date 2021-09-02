# terraform
PROJETO ESTUDOS TERRAFORM

1º PASSO Intalação do aws cli e terraform em sua maquina, seja ela windows ou linux, no caso na facil realizei o processo no próprio windows, um pouco mais complicado que no linux aparentemente.
Deve ser instalado a opçao do AWS CLI na maquina e posteriormente o terraform
AWS CLI
ao instalar o mesmo realizar o login do profile aws para poder construir com o terraform
comando: aws configure --profile user2 
AWS Access Key ID [None]: SUAKEY_ID 
AWS Secret Access Key [None]: SUA_KEY_ACCES 
Default region name [None]: us-east-1 
Default output format [None]: text

2ºPASSO
Na instalação do terraform via windows, deve ser realizado o download do arquivo do terraform direto do site do mesmo, e para "instalação" deve-se adicionar uma variavel de ambiente com a PATH C:\terraform, logicamente deve-se criar este diretório no mesmo local orientado , neste diretório deve ser descompactado o arquivo do download do site do terraform.

3ºPASSO
executar :  terraform -version
e verificar se foi instalado corretamente

4ºPASSO 
Download da ferramenta VSCODE tanto para windows quando para distribuições linux com tela gráfica
esta ferramenta facilita o processo.

5ºPASSO
No VSCODE realizar a instalação da extensão do terraform

6ºPASSO
Criar seu diretório Terraform, onde vai ficar todos os arquivos de estrutura via terraform, no meu caso criei um diretório em D:\terraform
Abrir este diretório pelo VSCODE , FILE>OPEN FOLDER>SEUDIRETÓRIO_TERRAFORM
Ainda dentro do VSCODE 
No seu diretório do terraform, selecione NEW FILE 
Nomeie o mesmo como main.tf que será o arquivo de construção da estrutura
Pode ter um arquivo para cada modulo exemplo: main.tf do S3 outro do EC2 e etc

7ºPASSO
Estrutura basica para criação de uma buckets3 
#ESTE INDICA A VERSÃO DO TERRAFORM

terraform {
    required_version = ">= 0.12.25"      
}

#(este indica seu provider, sendo aws, gcloud e demais, e a região do AZ)

provider "aws" {                                      
    region = "us-east-1"
}

#(este realiza a criação de um bucket na aws s3 com nome do bucket e a regra de acl)

resource "aws_s3_bucket" "terraform-teste-wayner2" {
    bucket = "waynerferreiraaws2"
    acl = "private"
}

#######################################
8ºpasso 
no vscode, na parte do terminal, provavelmente estará a opção do powershell ou terminal bash caso linux
da o comando
terraform init
para ele criar a estrutura que vc setou no codigo execute o comando
terraform plan
#no final do comando ele vai orientar que vai adicionar algo que vc esta solicitando e solicita o comando abaixo:
terraform apply
#por fim ele solicita mais uma permissão de yes / no:
yes
Por fim o processo é criado , podendo conferir via browser

Processo de vinculo com Github e Terraform Cloud

Realizado Vinculo da estrutura do códico Terraform no vscode maquina local , vinculado o mesmo no repositório Terraform em minha conta no github
Feito up de todos arquivos e vínculos com Github, Foi realizado o processo de conexão da minha estrutura GITHUB/TERRAFORM com a Ferramenta Terraform cloud 
Em minha conta do terraform , acessando pelo https://app.terraform.io/ , realizado a criação de uma organização em que esta, seria vinculada ao meu reposiório Github/terraform
Ao criar a organização no terraform cloud app, é passado variaveis de ambiente de acesso ao backend de minha estrutura no Terraform sendo AWS neste caso  e selecionado meu repo github.
Com isso foram interligados as seguintes ferramentas:
Vscode com aws cli / terraform
Vscode com estrutura terraform ao github repositório Terraform
Github repositório Terraform ao TERRAFORM CLOUD APP (ESTE QUE ATÉ O MOMENTO É O RESPONSÁVEL PELO APPLY)

Desta forma podemos atualizar a estrutua onde ela é analisada pelo APP TERRAFORM CLOUD após commit/push no github
Assim fica mais fácil vizualisar os processos que ocorrem ao ser realizado plan e apply da estrutura um Dashboard ideal para análise do mesmo.

Estrutura terraform:
Criado estrutura com :
VPC
2 SUBNETS  sendo subnet-testeA / subnet-testeb em Availability Zone ID
use1-az2 E use1-az4
Desta forma podemos criar instancias com acesso para internet e outras sem acesso para internet de acordo com as rotas projetadas, neste projeto não foi escolhido desta forma, mas é simples o detach para bloqueio de saida de internet das instancias
ROUTE TABLE - rt-teste com vinculo as duas subnets (pois a intenção serira simular somente instancias com faixa de ips diferentes por ser ambiente de testes e com isso ambas com saida para internet, fazendo estrutura de master-worker para k8s / docker swarm)
Netwok ACL - firewall para controlar o tráfego de entrada e saída, Neste caso por ser estrutura de teste de aplicação não ocorreram regras de boas práticas que demanda a segurança.
INTERNET GATEWAY -Attached na VPC para ter saida a internet
SECURITY GROUPS - para regras de ingress e egress das instancias e seus devidos vínculos
Lembrando ambiente de testes não foram consideradas as devidas precauções quanto a segurança.
Neste configurado All trafic como inbound e outbound rules e vinculado ao default

EC2
Criação de instancias
Criado instancias T2.MICRO para criação de um ambiente de testes com Docker e Docker swarm
Criado estrutura de Load Balancer e target groups para acesso a a portas específicas das aplicações (load balancer feito diretamente no dashboard aws (não tive tempo para replicar na esturura , mas o processo é relativamente simples como mostrado no exemplo abaixo, Tudo na documentação da Hashicorp/aws (Este seria um processo de "PROJETOS FUTUROS" a fazer para continuidade de toda a estrutura via Terraform, conTudo deve avaliar também os preços a serem pagos na aws, de toda estrutura que for montar varios recursos tem custos elevados dependendo da maneira utilizada:


resource "aws_elb" "bar" {
  name               = "foobar-terraform-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  access_logs {
    bucket        = "foo"
    bucket_prefix = "bar"
    interval      = 60
  }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 8000
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

  instances                   = [aws_instance.foo.id]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "foobar-terraform-elb"
  }
}

Com isso as estruturas criadas e realizado os determinádos vínculos , acesso as instancias , feito instalação docker docker swarm docker compose, criação de estruturas com yaml.
E os acessos nas aplicações são realizado via dns:porta DNS do load Balancer porta da aplicação com mesma porta Target Group.

Projetos futuros e com maior tempo, será utilizado Ferramenta Ansible para automatização de mais processos nas aplicações e vinculo com GITHUB ACTION, assim como feito na Estrutura do repositório do DESAFIO.

