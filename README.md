# terraform-docker-ecs

Infraestrutura como código para rodar uma API Django em containers no Amazon ECS com Fargate, provisionada com Terraform.

Projeto da formação de Infraestrutura como Código da Alura.

## Arquitetura

```
              ┌───────────────────────────┐
usuários ───► │ Application Load Balancer │ :8000   (subnets públicas)
              └─────────────┬─────────────┘
                            │
              ┌─────────────▼─────────────┐
              │ ECS Service (Fargate)     │ 3 tasks (subnets privadas)
              │ imagem vinda do ECR       │
              └───────────────────────────┘
```

| Arquivo | Recursos |
| --- | --- |
| [`infra/vpc.tf`](infra/vpc.tf) | VPC `10.0.0.0/16` com 3 subnets públicas, 3 privadas e NAT Gateway, usando o módulo `terraform-aws-modules/vpc` |
| [`infra/sg.tf`](infra/sg.tf) | Security group do ALB (entrada na `8000`) e das tasks (entrada só a partir do ALB) |
| [`infra/alb.tf`](infra/alb.tf) | Application Load Balancer, target group e listener na porta `8000` |
| [`infra/ecr.tf`](infra/ecr.tf) | Repositório de imagens no ECR |
| [`infra/iam.tf`](infra/iam.tf) | Role de execução com permissão para puxar imagens do ECR e gravar logs |
| [`infra/ecs.tf`](infra/ecs.tf) | Cluster ECS com Fargate, task definition (256 CPU / 512 MB) e service com 3 tasks |
| [`env/prod`](env/prod) | Ambiente de produção: chama o módulo e guarda o state em um bucket S3 |

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install)
- AWS CLI com credenciais no perfil `default`
- Docker, para buildar e enviar a imagem
- Um bucket S3 para o state remoto (ajuste o nome em [`env/prod/backend.tf`](env/prod/backend.tf))

## Como usar

```bash
cd env/prod
terraform init
terraform apply
```

O `apply` cria o repositório no ECR. Envie a imagem da aplicação para ele:

```bash
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin SUA_CONTA.dkr.ecr.us-east-2.amazonaws.com
docker tag SUA_IMAGEM SUA_CONTA.dkr.ecr.us-east-2.amazonaws.com/prod:v1
docker push SUA_CONTA.dkr.ecr.us-east-2.amazonaws.com/prod:v1
```

O endereço da imagem está fixo na task definition em [`infra/ecs.tf`](infra/ecs.tf); troque pelo da sua conta e rode `terraform apply` de novo.

O output `ip-alb` mostra o DNS do Load Balancer; a API responde em `http://DNS_DO_ALB:8000`. Para remover tudo, rode `terraform destroy`.

> O NAT Gateway e o Load Balancer são cobrados por hora. Destrua o ambiente quando terminar de estudar.

## Projetos relacionados

- [terraform-elasticbeanstalk-docker](https://github.com/ssdvd/terraform-elasticbeanstalk-docker): a mesma ideia com Elastic Beanstalk.
- [terraform-kubernetes](https://github.com/ssdvd/terraform-kubernetes): a mesma API no EKS.
- [terraform-djangoapp-project-ecs](https://github.com/ssdvd/terraform-djangoapp-project-ecs): esta arquitetura aplicada a uma aplicação própria.

As anotações das aulas estão em [`notes/`](notes).
