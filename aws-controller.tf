module "lb_role" {
    source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
    role_name                              = "${local.cluster_name}-${local.environment}-eks-lb"
    attach_load_balancer_controller_policy = true

    oidc_providers = {
        main = {
        provider_arn               = module.eks.oidc_provider_arn
        namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
        }
    }

    depends_on = [ null_resource.cluster_configured, null_resource.update_trust_policy ]
}

resource "kubernetes_service_account" "service-account" {
    metadata {
       name      = "aws-load-balancer-controller"
       namespace = "kube-system"
        labels = {
            "app.kubernetes.io/name"      = "aws-load-balancer-controller"
            "app.kubernetes.io/component" = "controller"
            "app.kubernetes.io/managed-by" = "Helm"
        }
        annotations = {
            "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
            "eks.amazonaws.com/sts-regional-endpoints" = "true"
            "meta.helm.sh/release-name"                = "aws-load-balancer-controller"
            "meta.helm.sh/release-namespace"           = "kube-system"
        }
   }
   depends_on = [ module.lb_role ]
}


resource "helm_release" "alb-controller" {
    name       = "aws-load-balancer-controller"
    repository = "https://aws.github.io/eks-charts"
    chart      = "aws-load-balancer-controller"
    namespace  = "kube-system"
    set {
        name  = "region"
        value = data.aws_region.current.name
    }
    set {
        name  = "vpcId"
        value = module.vpc.vpc_id
    }
    set {
        name  = "image.repository"
        value = "602401143452.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/amazon/aws-load-balancer-controller"
    }
    set {
        name  = "serviceAccount.create"
        value = "true"
    }
    set {
        name  = "serviceAccount.name"
        value = "aws-load-balancer-controller"
    }
    set {
        name  = "clusterName"
        value = module.eks.cluster_name
    }

    depends_on = [
        null_resource.cluster_configured,
        kubernetes_service_account.service-account
    ]
}