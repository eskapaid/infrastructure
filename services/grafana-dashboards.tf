data "template_file" "statsd_exporter_config" {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"
}

resource "kubernetes_config_map" "statsd_exporter" {
  metadata {
    name      = "statsd-exporter-config"
    namespace = "${kubernetes_namespace.monitoring.metadata.0.name}"
  }

  data = {
    "exporterConfiguration" = "${data.template_file.statsd_exporter_config.rendered}"
  }
}