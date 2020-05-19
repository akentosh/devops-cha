#Start a container
resource "docker_container" "paas" {
  name  = "paas"
  image = "akentosh/container-paas"
  ports {
    internal = "5000"
    external = "5000"
  }
}

# Pull the latest version
resource "docker_image" "paas" {
  name = "akentosh/container-paas:latest"
}
