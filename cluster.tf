module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.8.4"
  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version
  subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  cluster_endpoint_public_access = true
  create_node_security_group = true

  enable_irsa = true

  tags = {
    cluster = local.cluster_name
  }

  vpc_id = module.vpc.vpc_id
  authentication_mode = "API_AND_CONFIG_MAP"

  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    instance_types         = ["t2.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
    disk_size = 20
  }

  eks_managed_node_groups = {
    webapp = {
      subnet_ids = module.vpc.private_subnets
      create_security_group = false
      node_group = {
        min_size     = 2  
        max_size     = 2
        desired_size = 2
        
        iam_role_additional_policies = [
          "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore", 
          "arn:${local.partition}:iam::aws:policy/AmazonEKSWorkerNodePolicy",
          "arn:${local.partition}:iam::aws:policy/AmazonEKS_CNI_Policy",
          "arn:${local.partition}:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        ]
  
        labels = {
          AL2Nodes = "monitor"
        }
      }
    }
  }
  cluster_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  enable_cluster_creator_admin_permissions = false

  access_entries = {
    admin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${module.eks.cluster_iam_role_name}"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type  = "cluster"
          }
        }
      }
    }
    david = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/david"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            namespaces = []
            type  = "cluster"
          }
        }
      }
    }
  }
}

resource "null_resource" "list_load_balancers_on_destroy" {
  provisioner "local-exec" {
    when    = destroy
    command = "bash ${path.module}/scripts/delete_lbs.sh"
  }
}

resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --role-arn ${module.eks.cluster_iam_role_arn}"
  }

  depends_on = [module.eks]
}

resource "null_resource" "cluster_configured" {
  depends_on = [null_resource.update_kubeconfig]

  # Use triggers to force recreation if the kubeconfig is updated
  triggers = {
    kubeconfig_updated = "${null_resource.update_kubeconfig.id}"
  }
}