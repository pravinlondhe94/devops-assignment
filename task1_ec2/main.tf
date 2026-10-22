terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Protected instance resource
# Partitioned from var.instances where prevent_destroy is true.
# Evaluated statically by Terraform compile-time lifecycle rules.
resource "aws_instance" "protected" {
  for_each = {
    for name, config in var.instances : name => config
    if coalesce(config.prevent_destroy, false)
  }

  ami           = coalesce(each.value.ami_id, var.ami_id)
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_type           = each.value.root_volume_type
    volume_size           = each.value.root_volume_size
    iops                  = contains(["io1", "io2", "gp3"], each.value.root_volume_type) ? each.value.iops : null
    throughput            = each.value.root_volume_type == "gp3" ? each.value.throughput : null
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name        = "${each.key}-root-vol"
      Environment = each.value.environment
      Owner       = each.value.owner
    }
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Standard instances resource
# Driven from the remaining items in the single var.instances map.
resource "aws_instance" "standard" {
  for_each = {
    for name, config in var.instances : name => config
    if !coalesce(config.prevent_destroy, false)
  }

  ami           = coalesce(each.value.ami_id, var.ami_id)
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_type           = each.value.root_volume_type
    volume_size           = each.value.root_volume_size
    iops                  = contains(["io1", "io2", "gp3"], each.value.root_volume_type) ? each.value.iops : null
    throughput            = each.value.root_volume_type == "gp3" ? each.value.throughput : null
    delete_on_termination = true
    encrypted             = true

    tags = {
      Name        = "${each.key}-root-vol"
      Environment = each.value.environment
      Owner       = each.value.owner
    }
  }

  tags = {
    Name        = each.key
    Environment = each.value.environment
    Owner       = each.value.owner
  }
}
