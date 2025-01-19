terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

#provider "yandex" {
#  service_account_key_file = file("~/.authorized_key.json")
#  cloud_id  = "${var.yandex_cloud_id}"
#  folder_id = "${var.yandex_folder_id}"
#}

provider "yandex" {
  token     = var.token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.zone_a
}
