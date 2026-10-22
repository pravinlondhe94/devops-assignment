aws_region = "us-east-1"

instances = {
  "web-frontend" = {
    instance_type    = "t3.micro"
    root_volume_type = "gp2"
    root_volume_size = 30
    key_name         = "kp-web-frontend"
    environment      = "Production"
    owner            = "FrontendTeam"
    prevent_destroy  = false
  }

  "api-gateway" = {
    instance_type    = "t3.small"
    root_volume_type = "gp3"
    root_volume_size = 50
    iops             = 3000
    throughput       = 125
    key_name         = "kp-api-gateway"
    environment      = "Production"
    owner            = "BackendTeam"
    prevent_destroy  = false
  }

  "worker-node" = {
    instance_type    = "c6i.large"
    root_volume_type = "standard"
    root_volume_size = 100
    key_name         = "kp-worker-node"
    environment      = "Production"
    owner            = "DataPlatform"
    prevent_destroy  = false
  }

  "cache-cluster" = {
    instance_type    = "m6i.large"
    root_volume_type = "io1"
    root_volume_size = 150
    iops             = 3000
    key_name         = "kp-cache-cluster"
    environment      = "Production"
    owner            = "InfraTeam"
    prevent_destroy  = false
  }

  "db-primary" = {
    instance_type    = "r6i.xlarge"
    root_volume_type = "io2"
    root_volume_size = 250
    iops             = 5000
    key_name         = "kp-db-primary"
    environment      = "Production"
    owner            = "DatabaseAdmin"
    prevent_destroy  = true
  }
}
