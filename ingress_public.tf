resource "kubernetes_namespace" "example_public" {
  metadata {
    name = "public"
  }
}

resource "kubernetes_ingress" "example_public" {
  metadata {
    name        = "example-ingress"
    namespace   = "public"
    annotations = {
      "kubernetes.io/ingress.class"      = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type": "ip"
    }
  }

  spec {
    rule {
      host = "example.com.bo"

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