// Загрузка объекта
resource "yandex_storage_object" "test-image-1" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "egorkin-netology-bucket"
  key        = "egorkin1.jpg"
  source     = "egorkin1.jpg"
  acl        = "public-read"
  depends_on = [yandex_storage_bucket.netology-cluster-bucket]

}

resource "yandex_storage_object" "test-image-2" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "egorkin-netology-bucket"
  key        = "egorkin1.png"
  source     = "egorkin1.png"
  acl        = "public-read"
  depends_on = [yandex_storage_bucket.netology-cluster-bucket]
}

resource "yandex_storage_object" "test-image-3" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "egorkin-netology-bucket"
  key        = "egorkin1.jpg"
  source     = "egorkin1.jpg"
  acl        = "public-read"
  depends_on = [yandex_storage_bucket.kms-netology-ru]

}

resource "yandex_storage_object" "test-image-4" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "egorkin-netology-bucket"
  key        = "egorkin1.png"
  source     = "egorkin1.png"
  acl        = "public-read"
  depends_on = [yandex_storage_bucket.kms-netology-ru]
}
