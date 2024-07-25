resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --role-arn ${module.eks.cluster_iam_role_arn}"
  }

  depends_on = [module.eks]
}


resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "5.46.0"
  create_namespace = true

  values = [
    file("${path.root}/deployment/argocd.yaml")
  ]

  depends_on = [ null_resource.update_kubeconfig ]
}


resource "null_resource" "argo_portfoward" {
  provisioner "local-exec" {
    command = "nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &"

  }
  depends_on = [helm_release.argocd]
}


resource "null_resource" "argo_login" {
  provisioner "local-exec" {
    command = <<EOT
      ARGOCD_SERVER=$(kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname')
      ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
      sleep 15
      argocd login $ARGOCD_SERVER --username admin --password $ARGO_PWD --insecure
      EOT
  }

  depends_on = [null_resource.argo_portfoward]
}
