##dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id    = "datasetJMA"
  friendly_name = "datasetJMA"
  description   = "気象庁のcsvデータを格納する。"
  location      = "asia-northeast1"
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

##dwhMaxtemJMA#################################
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

##dwhMintemJMA#################################
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

##dwhPredailyJMA###############################
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