variable "container_tag" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "mastodon_domain" {
  type = string
}

variable "rails_port" {
  type = string
}

variable "redis_host" {
  type = string
}

variable "redis_port" {
  type = string
}

variable "rds_password" {
  type = string
}

variable "rds_user" {
  type = string
}

variable "rds_name" {
  type = string
}

variable "rds_port" {
  type = string
}

variable "es_enabled" {
  type = string
}

variable "es_host" {
  type = string
}

variable "es_port" {
  type = string
}

variable "es_user" {
  type = string
}

variable "es_password" {
  type = string
}

variable "rails_secret_key_base" {
  type = string
}

variable "rails_otp_secret" {
  type = string
}

variable "rails_push_private_key" {
  type = string
}

variable "rails_push_public_key" {
  type = string
}

variable "smtp_server" {
  type = string
}

variable "smtp_port" {
  type = string
}

variable "smtp_user" {
  type = string
}

variable "smtp_password" {
  type = string
}

variable "smtp_from_address" {
  type = string
}

variable "s3_enabled" {
  type = string
}

variable "s3_permission" {
  type = string
}

variable "s3_endpoint" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_access_key" {
  type = string
}

variable "s3_bucket_secret_key" {
  type = string
}

variable "s3_alias_host" {
  type = string
}

variable "ip_retention_period" {
  type = string
}

variable "session_retention_period" {
  type = string
}

variable "streaming_port" {
  type = string
}

job "mastodon-web" {
  datacenters = ["eu_west_1"]
  priority    = 90

  group "app" {
    count = 1

    network {
      mode = "host"
      port "rails" {
        static       = var.rails_port
        to           = var.rails_port
        host_network = "loopback"
      }
    }

    task "web" {
      driver = "docker"

      service {
        name = "web"
        port = "rails"

        check {
          type     = "http"
          port     = "rails"
          interval = "5s"
          timeout  = "5s"
          path     = "/health"
        }
      }

      config {
        image        = "tootsuite/mastodon:${var.container_tag}"
        ports        = ["rails"]
        network_mode = "host"
        args = [
          "bash",
          "-c",
          "bundle exec rails s -p ${var.rails_port}"
        ]
      }

      resources {
        cpu    = 500
        memory = 1000
      }

      env {
        LOCAL_DOMAIN             = var.mastodon_domain
        REDIS_HOST               = var.redis_host
        REDIS_PORT               = var.redis_port
        DB_HOST                  = var.rds_endpoint
        DB_USER                  = var.rds_user
        DB_NAME                  = var.rds_name
        DB_PASS                  = var.rds_password
        DB_PORT                  = var.rds_port
        ES_ENABLED               = var.es_enabled
        ES_HOST                  = var.es_host
        ES_PORT                  = var.es_port
        ES_USER                  = var.es_user
        ES_PASS                  = var.es_password
        SECRET_KEY_BASE          = var.rails_secret_key_base
        OTP_SECRET               = var.rails_otp_secret
        VAPID_PRIVATE_KEY        = var.rails_push_private_key
        VAPID_PUBLIC_KEY         = var.rails_push_public_key
        SMTP_SERVER              = var.smtp_server
        SMTP_PORT                = var.smtp_port
        SMTP_LOGIN               = var.smtp_user
        SMTP_PASSWORD            = var.smtp_password
        SMTP_FROM_ADDRESS        = var.smtp_from_address
        S3_ENABLED               = var.s3_enabled
        S3_ENDPOINT              = var.s3_endpoint
        S3_BUCKET                = var.s3_bucket_name
        S3_PERMISSION            = var.s3_permission
        AWS_ACCESS_KEY_ID        = var.s3_bucket_access_key
        AWS_SECRET_ACCESS_KEY    = var.s3_bucket_secret_key
        S3_ALIAS_HOST            = var.s3_alias_host
        IP_RETENTION_PERIOD      = var.ip_retention_period
        SESSION_RETENTION_PERIOD = var.session_retention_period
        STATSD_ADDR              = "${attr.unique.network.ip-address}:8125"
      }
    }
  }
}