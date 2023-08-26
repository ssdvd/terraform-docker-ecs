module "prod" {
  source = "../../infra"

  nome-repo = "prod"
  cargo-iam = "prod"

  output "ip-alb" {
    value = module.prod.IP
  }
}
