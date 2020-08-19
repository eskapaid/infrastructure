resource "kubernetes_service_account" "admin_user" {
  metadata {
    name      = "admin-user"
    namespace = kubernetes_namespace.services.metadata.0.name
  }
  automount_service_account_token = false
}

resource "kubernetes_cluster_role_binding" "admin_user" {
  metadata {
    name = "admin-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin_user.metadata.0.name
    namespace = kubernetes_namespace.services.metadata.0.name
  }
}