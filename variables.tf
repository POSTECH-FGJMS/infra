variable "db_username" {
  description = "Username Database"
  type        = string
}

variable "db_password" {
  description = "Password Database"
  type        = string
  sensitive   = true
}