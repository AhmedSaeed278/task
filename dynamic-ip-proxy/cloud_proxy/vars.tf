variable "allowed_ips" {
  type = list(string)
  description = "List of IPs allowed to access the proxy."
}

variable "username" {
  type = string
  description = "Username for proxy authentication."
}

variable "password" {
  type = string
  description = "Password for proxy authentication."
}

#variable "life_hours" {
#  type = number
#  description = "Time interval (in hours) to rotate the proxy instance."
#}

variable "key_name" {
  type = string
  description = "Name of the AWS key pair."
}

variable "subnet_id" {
  type = string
  description = "AWS subnet ID for the EC2 instance."
}
variable "life_minutes" {
  type = number
  description = "Time interval (in minutes) to rotate the proxy instance."
}