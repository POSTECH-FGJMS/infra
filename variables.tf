variable "db_username" {
  description = "Username Database"
  type        = string
}

variable "db_password" {
  description = "Password Database"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "Vpc Id"
  type        = string
  sensitive   = true
}

variable "subnet_id1" {
  description = "Subnet Id 1"
  type        = string
  sensitive   = true
}

variable "subnet_id2" {
  description = "Subnet Id 2"
  type        = string
  sensitive   = true
}