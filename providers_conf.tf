data "aws_eks_cluster" "my_eks_cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "my_eks_cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.my_eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my_eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.my_eks_cluster.token
}
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.my_eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.my_eks_cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.my_eks_cluster.token
  }
}