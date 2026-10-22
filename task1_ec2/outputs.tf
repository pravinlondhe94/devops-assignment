output "instance_ids" {
  description = "Map of EC2 instance name to instance ID"
  value = {
    for name, inst in merge(aws_instance.protected, aws_instance.standard) :
    name => inst.id
  }
}

output "private_ips" {
  description = "Map of EC2 instance name to private IP address"
  value = {
    for name, inst in merge(aws_instance.protected, aws_instance.standard) :
    name => inst.private_ip
  }
}
