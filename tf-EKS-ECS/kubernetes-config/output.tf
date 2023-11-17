output "kubeconfig" {
  value = abspath("${path.root}/${local_file.kubeconfig.filename}")
}

output "service_ip" {
  value = kubernetes_manifest.nginx-webserver["Service"]["your-service"].status[0].loadBalancer.ingress[0].ip
}