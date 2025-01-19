variable "yandex_cloud_id" {
  default = "***"
}

variable "yandex_folder_id" {
  default = "***"
}

variable "instance-nat-ip" {
  default = "192.168.10.254"
}

variable "domain" {
  default = "netology.cloud"
}

variable "user_name" {
  description = "VM User Name"
  default     = "ubuntu"
}

variable "user_ssh_key_path" {
  description = "User's SSH public key file"
  default     = "~/.ssh/id_ed25519.pub"
}

variable "token" {
  type        = string
  default     = "***"
  sensitive   = true
}

variable "zone_a" {
  default = "ru-central1-a"
}
