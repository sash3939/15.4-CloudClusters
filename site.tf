// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "kms-netology-ru" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "kms-netology.ru"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  https {
    certificate_id = "fpq7oou0epissarql1dn"
  }

  depends_on = [yandex_iam_service_account_static_access_key.sa-static-key]
}

// Загрузка объекта
resource "yandex_storage_object" "index_document" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "kms-netology.ru"
  key        = "index.html"
  source     = "index.html"
  acl        = "public-read"
  depends_on = [yandex_storage_bucket.kms-netology-ru]

}
