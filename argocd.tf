resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd" 
  version          = "5.46.0"
  create_namespace = true

  values = [
    templatefile("${path.root}/deployment/argocd.yaml", {
      subnet_ids = join(",", module.vpc.public_subnets)
    })
  ]

  depends_on = [ null_resource.cluster_configured ]
}


resource "null_resource" "argo_portfoward" {
  provisioner "local-exec" {
    command = "nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &"

  }
  depends_on = [helm_release.argocd]
}


resource "null_resource" "argo_login" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/argocd_login.sh"
  }

  depends_on = [null_resource.argo_portfoward, aws_iam_role.eks_cluster_role]
}

data "external" "argocd_lb_hostname" {
  program = ["bash", "${path.module}/scripts/fetch_argocd_lb_hostname.sh"]
  depends_on = [ null_resource.argo_login ]
}