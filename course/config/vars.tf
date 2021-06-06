
variable "region" {
  description = "The current AWS region. It is set via 'export TF_VAR_region=...' from AWS_DEFAULT_REGION in the '~/.bashrc' of the course container."
  type = string
}
