variable "container_tag" {
  type = string
}

job "mastodon-front" {
  datacenters = ["eu_west_1"]
  priority    = 90

  group "front" {
    count = 1 # TODO: this can't be increased due to static port assignments

    network {
      mode = "host"

      port "http" {
        static = 80
        to = 80
        host_network = "network_eth0"
      }
      port "https" {
        static = 443
        to = 443
        host_network = "network_eth0"
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:${var.container_tag}"
        ports = ["http", "https"]
        network_mode = "host"
        volumes = [
          "local/conf.d:/etc/nginx/conf.d",
          "local/nginx.conf:/etc/nginx/nginx.conf",
        ]
      }

      resources {
        cpu = 300
        memory = 300
      }

      template {
        data = file("./files/nginx-selfsigned.crt")
        destination   = "local/conf.d/nginx-selfsigned.crt"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        left_delimiter = "<<"
        right_delimiter = ">>"
      }

      template {
        data = file("./files/nginx-selfsigned.key")
        destination   = "local/conf.d/nginx-selfsigned.key"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        left_delimiter = "<<"
        right_delimiter = ">>"
      }

      template {
        data = file("./files/mastodon.conf")
        destination   = "local/conf.d/mastodon.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        left_delimiter = "<<"
        right_delimiter = ">>"
      }

      template {
        data = file("./files/nginx.conf")
        destination   = "local/nginx.conf"
        change_mode   = "restart"
        change_signal = "SIGHUP"
        left_delimiter = "<<"
        right_delimiter = ">>"
      }
    }
  }
}