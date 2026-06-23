variable "db_username" {
  description = "Username for the database"
  type = string
  sensitive = false
}

variable "db_password" {
  description = "Password for the database"
  type = string
  sensitive = true
}