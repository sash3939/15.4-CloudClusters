// kms_symmetric_key
resource "yandex_kms_symmetric_key" "key-a" {
  name              = "netology-symetric-key"
  description       = "netology-symetric-key"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" // equal to 1 year
}
