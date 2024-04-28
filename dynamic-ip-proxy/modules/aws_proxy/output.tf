output "proxy_url" {
  description = "Public URL of the proxy server"
  value = aws_instance.proxy.public_dns
}
