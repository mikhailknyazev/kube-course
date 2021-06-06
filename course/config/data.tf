data "terraform_remote_state" "kube" {
  backend = "local"

  config = {
    path = "${path.module}/../kube/terraform.tfstate"
  }
}
