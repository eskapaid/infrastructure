locals {
  metrics_scraper_version = "v1.0.5"
}

resource "kubernetes_service" "dashboard_metrics_scraper" {
  metadata {
    name      = "dashboard-metrics-scraper"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "dashboard-metrics-scraper"
    }
  }

  spec {
    port {
      port        = "8000"
      target_port = "8000"
    }

    selector = {
      k8s-app = "dashboard-metrics-scraper"
    }
  }
}

resource "kubernetes_deployment" "dashboard_metrics_scraper" {
  metadata {
    name      = "dashboard-metrics-scraper"
    namespace = kubernetes_namespace.monitor.metadata.0.name

    labels = {
      k8s-app = "dashboard-metrics-scraper"
    }
  }

  spec {
    replicas               = "1"
    revision_history_limit = "10"

    selector {
      match_labels = {
        k8s-app = "dashboard-metrics-scraper"
      }
    }

    template {
      metadata {
        namespace = kubernetes_namespace.monitor.metadata.0.name

        labels = {
          k8s-app = "dashboard-metrics-scraper"
        }

        annotations = {
          "seccomp.security.alpha.kubernetes.io/pod" = "runtime/default"
        }
      }

      spec {
        container {
          name  = "dashboard-metrics-scraper"
          image = "kubernetesui/metrics-scraper:${local.metrics_scraper_version}"

          port {
            container_port = "8000"
            protocol       = "TCP"
          }

          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              scheme = "HTTP"
              path   = "/"
              port   = "8000"
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
          name = "tmp-volume"
          empty_dir {}
        }

        service_account_name            = "kubernetes-dashboard"
        automount_service_account_token = true
      }
    }
  }
}