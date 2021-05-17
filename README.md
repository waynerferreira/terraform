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


# (este indica a versão do terraform)
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


