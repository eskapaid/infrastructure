locals {
  dashboard_version = "v2.0.3"
}

resource "kubernetes_secret" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard-certs"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  type = "Opaque"
}

resource "kubernetes_secret" "kubernetes_dashboard_csrf" {
  metadata {
    name      = "kubernetes-dashboard-csrf"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  data = {}

  type = "Opaque"

  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_secret" "kubernetes_dashboard_key_holder" {
  metadata {
    name      = "kubernetes-dashboard-key-holder"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  data = {}

  type = "Opaque"

  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_service_account" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  automount_service_account_token = false
}

resource "kubernetes_config_map" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard-settings"
    namespace = kubernetes_namespace.monitor.metadata.0.name
  }
}

resource "kubernetes_role" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.monitor.metadata.0.name
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["kubernetes-dashboard-settings"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs", "kubernetes-dashboard-csrf"]
    verbs          = ["get", "update", "delete"]
  }

  rule {
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["heapster", "dashboard-metrics-scraper"]
    verbs          = ["proxy"]
  }

  rule {
    api_groups     = [""]
    resources      = ["services/proxy"]
    resource_names = ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
    verbs          = ["get"]
  }
}

resource "kubernetes_role_binding" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.monitor.metadata.0.name
  }

  role_ref {
    name      = "kubernetes-dashboard"
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
  }

  subject {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.monitor.metadata.0.name
    kind      = "ServiceAccount"
    api_group = ""
  }
}

resource "kubernetes_cluster_role" "kubernetes_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }

  # Allow Metrics Scraper to get metrics from the Metrics server
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "kubernetes_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }

  role_ref {
    name      = "kubernetes-dashboard"
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
  }

  subject {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.monitor.metadata.0.name
    kind      = "ServiceAccount"
    api_group = ""
  }
}

resource "kubernetes_deployment" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  spec {
    replicas               = "1"
    revision_history_limit = "10"

    selector {
      match_labels = {
        k8s-app = "kubernetes-dashboard"
      }
    }

    template {
      metadata {
        namespace = kubernetes_namespace.monitor.metadata.0.name

        labels = {
          k8s-app = "kubernetes-dashboard"
        }
      }

      spec {
        container {
          name  = "kubernetes-dashboard"
          image = "kubernetesui/dashboard:${local.dashboard_version}"

          port {
            container_port = "8443"
            protocol       = "TCP"
          }

          args = [
            "--auto-generate-certificates",
            "--namespace=${kubernetes_namespace.monitor.metadata.0.name}",
            "--token-ttl=43200",
            "--system-banner=${upper("Environment:${var.environment}")}",
            "--system-banner-severity=WARNING",
          ]

          volume_mount {
            name       = "kubernetes-dashboard-certs"
            mount_path = "/certs"
          }

          volume_mount {
            name       = "kubernetes-dashboard-key-holder"
            mount_path = "/key-holder"
          }

          volume_mount {
            name       = "kubernetes-dashboard-csrf"
            mount_path = "/csrf"
          }

          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          volume_mount {
            name       = "service-account-token-${kubernetes_service_account.kubernetes_dashboard.default_secret_name}"
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
            read_only  = true
          }

          resources {
            limits {
              cpu    = "250m"
              memory = "192Mi"
            }
            requests {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          liveness_probe {
            http_get {
              scheme = "HTTPS"
              path   = "/"
              port   = "8443"
            }

            initial_delay_seconds = "30"
            timeout_seconds       = "30"
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true
            run_as_user                = 1001
            run_as_group               = 2001
          }
        }

        volume {
          name = "kubernetes-dashboard-certs"

          secret {
            secret_name = "kubernetes-dashboard-certs"
          }
        }

        volume {
          name = "kubernetes-dashboard-key-holder"

          secret {
            secret_name = "kubernetes-dashboard-key-holder"
          }
        }

        volume {
          name = "kubernetes-dashboard-csrf"

          secret {
            secret_name = "kubernetes-dashboard-csrf"
          }
        }

        volume {
          name = "tmp-volume"
          empty_dir {}
        }

        volume {
          name = "service-account-token-${kubernetes_service_account.kubernetes_dashboard.default_secret_name}"

          secret {
            secret_name = kubernetes_service_account.kubernetes_dashboard.default_secret_name
          }
        }

        service_account_name = "kubernetes-dashboard"
      }
    }
  }
}

resource "kubernetes_service" "kubernetes_dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }

  spec {
    port {
      port        = "443"
      target_port = "8443"
    }

    type = "NodePort"

    selector = {
      k8s-app = "kubernetes-dashboard"
    }
  }
}

# resource "kubernetes_ingress" "kubernetes_dashboard" {
#   metadata {
#     name      = "kubernetes-dashboard"
#     namespace  = kubernetes_namespace.monitor.metadata.0.name
#     annotations = {
#       "kubernetes.io/ingress.class"           = "alb"
#       "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
#       "alb.ingress.kubernetes.io/target-type" = "ip"
#     }
#     labels = {
#         k8s-app = "kubernetes-dashboard"
#     }
#   }

#   spec {
#     rule {
#       http {
#         path {
#           path = "/*"
#           backend {
#             service_name = kubernetes_service.kubernetes_dashboard.metadata[0].name
#             service_port = kubernetes_service.kubernetes_dashboard.spec[0].port[0].port
#           }
#         }
#       }
#     }
#   }

#   depends_on = [kubernetes_service.kubernetes_dashboard]
# }