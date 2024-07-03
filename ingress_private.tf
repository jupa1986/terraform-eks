resource "kubernetes_namespace" "example" {
  metadata {
    name = "private"
  }
}

resource "kubernetes_ingress" "example" {
  metadata {
    name        = "example-ingress"
    namespace   = "private"
    annotations = {
      "kubernetes.io/ingress.class"      = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internal"
    }
  }

  spec {
    rule {
      host = "example.com"

      http {
        path {
          path = "/"
          backend {
            service_name = "example-service"
            service_port = "80"
          }
        }
      }
    }
  }
}