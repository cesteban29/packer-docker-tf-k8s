
packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

locals{
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


# Define the builder for Docker
source "docker" "nginx" {
  # Use the official Nginx base image
  image        = "nginx:latest"
  export_path  = "nginx_server.tar"
}

# Build configuration
build {
  name = "docker-nginx-image"

  hcp_packer_registry {
      bucket_name = "docker-demo"
      description = <<EOT
      Docker image with NGINX webserver
      EOT
      bucket_labels = {
        "container"             = "Docker",
      }

      build_labels = {
         "build-time"   = timestamp()
      }
  }

  sources = ["source.docker.nginx"]

  # Post-processors for pushing the image to ECR
  
  post-processors{
    post-processor "docker-import"{
      repository = "nginx-webserver"
      tag = "0.3"
    }

    post-processor "docker-tag"{
      repository = "803343860563.dkr.ecr.us-west-2.amazonaws.com/docker-demo"
      tag = ["latest"]
    }

    post-processor "docker-push" {
        ecr_login = true
        login_server = "803343860563.dkr.ecr.us-west-2.amazonaws.com/docker-demo"
    }

  } 
  

}