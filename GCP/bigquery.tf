##dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id    = "datasetJMA"
  friendly_name = "datasetJMA"
  description   = "気象庁のcsvデータを格納する。"
  location      = "asia-northeast1"
}

##Dataform
resource "google_secret_manager_secret" "dataform_JMA_git" {
  provider  = google-beta
  secret_id = "dataform_JMA_git"
  replication {
    auto {}
  }
}
resource "google_secret_manager_secret_version" "dataform_JMA_git_version" {
  provider    = google-beta
  secret      = google_secret_manager_secret.dataform_JMA_git.id
  secret_data = var.authentication_token_secret
}

resource "google_secret_manager_secret_iam_member" "member" {
  provider  = google-beta
  secret_id = google_secret_manager_secret.dataform_JMA_git.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.dataform_service_account}"
}
resource "google_dataform_repository" "dataform_repository" {
  provider = google-beta
  name = "repository_JMA"
  display_name = "repository_JMA"
  region = "asia-northeast1"
  service_account = "${var.dataform_service_account}"
  git_remote_settings {
      url = "https://github.com/Yuno-nekoisland/DatapiplineJMA.git"
      default_branch = "main"
      authentication_token_secret_version = google_secret_manager_secret_version.dataform_JMA_git_version.id
  }
}

##table
###datalake
###dlMaxtemJMA##################################
resource "google_bigquery_table" "dlMaxtemJMA" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "dlMaxtemJMA"
  project    = var.project_id
  schema     = file("./BigQuery/dlMaxtemJMA.json")
  external_data_configuration {
    autodetect = false
    source_uris = [
      "gs://download_file_jma/maxtemperature/*.csv",
    ]
    csv_options {
      quote             = ""
      skip_leading_rows = 1
    }
    source_format = "CSV"
  }
  deletion_protection = false
}

###dlMintemJMA##################################
resource "google_bigquery_table" "dlMintemJMA" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "dlMintemJMA"
  project    = var.project_id
  schema     = file("./BigQuery/dlMintemJMA.json")
  external_data_configuration {
    autodetect = false
    source_uris = [
      "gs://download_file_jma/mintemperature/*.csv",
    ]
    csv_options {
      quote             = ""
      skip_leading_rows = 1
    }
    source_format = "CSV"
  }
  deletion_protection = false
}

###dlPredailyJMA################################
resource "google_bigquery_table" "dlPredailyJMA" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "dlPredailyJMA"
  project    = var.project_id
  schema     = file("./BigQuery/dlPredailyJMA.json")
  external_data_configuration {
    autodetect = false
    source_uris = [
      "gs://download_file_jma/predaily/*.csv",
    ]
    csv_options {
      quote             = ""
      skip_leading_rows = 1
    }
    source_format = "CSV"
  }
  deletion_protection = false
}

##datawarehouse
###dwhMaxtemJMA#################################
resource "google_bigquery_table" "dwhMaxtemJMA" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "dwhMaxtemJMA"
  deletion_protection = false
  clustering          = ["observatoryNo"]
  #time_partitioning {
  #  field                    = "dateday"
  #  type                     = "DAY"
  #  require_partition_filter = true
  #}
  schema = file("./BigQuery/dwhMaxtemJMA.json")
}

###dwhMintemJMA#################################
resource "google_bigquery_table" "dwhMintemJMA" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "dwhMintemJMA"
  deletion_protection = false
  clustering          = ["observatoryNo"]
  #time_partitioning {
  #  field                    = "dateday"
  #  type                     = "DAY"
  #  require_partition_filter = true
  #}
  schema = file("./BigQuery/dwhMintemJMA.json")

}

###dwhPredailyJMA###############################
resource "google_bigquery_table" "dwhPredailyJMA" {
  dataset_id          = google_bigquery_dataset.dataset.dataset_id
  table_id            = "dwhPredailyJMA"
  deletion_protection = false
  clustering          = ["observatoryNo"]
  #time_partitioning {
  #  field                    = "dateday"
  #  type                     = "DAY"
  #  require_partition_filter = true
  #}
  schema = file("./BigQuery/dwhPredailyJMA.json")
}