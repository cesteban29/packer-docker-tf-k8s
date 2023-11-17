data "aws_eks_cluster" "eks-cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks-cluster-auth" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks-cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks-cluster-auth.token
}

resource "local_sensitive_file" "kubeconfig" {
  content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name = "${var.cluster_name}",
    clusterca    = "${data.aws_eks_cluster.eks-cluster.certificate_authority[0].data}",
    endpoint     = "${data.aws_eks_cluster.eks-cluster.endpoint}",
  })
  filename = "./kubeconfig-${var.cluster_name}"
}

resource "kubernetes_manifest" "nginx-webserver" {
  manifest = {
      apiVersion = "apps/v1"
      kind       = "Deployment"
      metadata = {
        name = "your-deployment"
      }
      spec = {
        replicas = 1
        selector = {
          matchLabels = {
            app = "your-app"
          }
        }
        template = {
          metadata = {
            labels = {
              app = "your-app"
            }
          }
          spec = {
            containers = [
              {
                name  = "nginx-webserver"
                image = "${data.hcp_packer_image.nginx-image.labels["tags"]}"
              }
            ]
          }
        }
      }
  }
}