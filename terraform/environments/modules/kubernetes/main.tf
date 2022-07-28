#------------------------------------------------------------------------------
# written by: Lawrence McDaniel
#             https://lawrencemcdaniel.com
#
# date: April 2022
# Updated: July 
# usage: Create an EKS Cluster
# 
#------------------------------------------------------------------------------
data "aws_eks_cluster" "eks" {
  name = var.resource_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.resource_name
}

data "aws_eks_cluster_auth" "cluster-auth" {
  name       = var.resource_name
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

#------------------------------------------------------------------------------
# Tutor deploys into this namespace, bc of a namesapce command-line argument
# that we pass inside of GitHub Actions deploy workflow
#------------------------------------------------------------------------------
resource "kubernetes_namespace" "openedx" {
  metadata {
    name = "openedx-${var.environment_name}"
  }
  depends_on = [data.aws_eks_cluster.eks]
}

provider "helm" {
  alias = var.resource_name
  kubernetes {
    host                   = aws_eks_cluster.my_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.my_cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster-auth.token
    load_config_file       = false
  }
}