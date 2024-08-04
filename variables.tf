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

variable "eks_iam_username" {
  description = "List of IAM usernames to allow access to EKS cluster"
  type        = string
  default     = "david"
}

variable "cluster_iam_username" {
  description = "IAM username to access EKS cluster"
  type        = list(string)
  default     = ["eksadmin", "davideks"]
}