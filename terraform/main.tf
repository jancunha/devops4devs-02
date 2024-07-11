resource "digitalocean_kubernetes_cluster" "main" {
  name    = var.k8s_name
  region  = var.region
  version = var.ver

  node_pool {
    name       = "default"
    size       = var.size
    node_count = 3
  }
}

resource "local_file" "kube_config" {
  content  = digitalocean_kubernetes_cluster.main.kube_config.0.raw_config
  filename = "kubeconfig.yaml"
}