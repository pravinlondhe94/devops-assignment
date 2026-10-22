variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "Default AMI ID for EC2 instances (can be overridden in instances variable)"
  type        = string
  default     = "ami-0c7217cdde317cfec" # Amazon Linux 2023 AMI in us-east-1
}

variable "instances" {
  description = "Map of EC2 instance configurations to provision"
  type = map(object({
    instance_type    = string
    ami_id           = optional(string)
    root_volume_type = string
    root_volume_size = number
    iops             = optional(number)
    throughput       = optional(number)
    key_name         = string
    environment      = string
    owner            = string
    prevent_destroy  = optional(bool, false)
  }))

  validation {
    condition     = length(var.instances) == 5
    error_message = "Exactly 5 EC2 instances must be defined in the instances map."
  }

  validation {
    condition = anytrue([
      for inst in var.instances : contains(["io1", "io2"], inst.root_volume_type)
    ])
    error_message = "At least one instance must use io1 or io2 storage."
  }

  validation {
    condition = length(distinct([
      for inst in var.instances : inst.instance_type
    ])) == length(var.instances)
    error_message = "Every instance must have a unique instance_type."
  }

  validation {
    condition = length(distinct([
      for inst in var.instances : inst.root_volume_type
    ])) == length(var.instances)
    error_message = "Every instance must have a unique root_volume_type."
  }

  validation {
    condition = length(distinct([
      for inst in var.instances : inst.root_volume_size
    ])) == length(var.instances)
    error_message = "Every instance must have a unique root_volume_size."
  }

  validation {
    condition = length(distinct([
      for inst in var.instances : inst.key_name
    ])) == length(var.instances)
    error_message = "Every instance must have a unique key_name."
  }
}
