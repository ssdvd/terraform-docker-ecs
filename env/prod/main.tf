module "prod" {
    source = "../../infra"

    nome-repo = "prod"
    cargo-iam = "prod"
    
}