variable "kubernetes_version" {
  default     = 1.28
  description = "kubernetes version"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "default CIDR range of the VPC"
}

variable "domain_name" {
  default = "awsdjangodeployer.com"
  description = "Registrar domain name"
}