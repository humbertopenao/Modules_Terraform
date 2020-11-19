resource "consul_node" "es" {
  name    = var.es_consul_service
  address = var.es_endpoint
}

resource "consul_service" "es" {
  node = consul_node.es.name
  name = var.es_consul_service
  port = var.es_default_access["port"]
}
