
variable "region" {
  description = "The current AWS region. It is set via 'export TF_VAR_region=...' from AWS_DEFAULT_REGION in the '~/.bashrc' of the course container."
  type = string
}

variable "node_termination_handler_webhook_url" {
  description = "If specified and the node-termination-handler has been installed, then the latter sends notifications to it."
  type = string
  default = ""
}
