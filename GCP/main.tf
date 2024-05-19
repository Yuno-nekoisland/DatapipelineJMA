provider "google" {
  credentials = file("${var.credential.data}")
  project     = var.project_id
  region      = "asia-northeast1"
}

locals {
  cs_foldernames = {
    folder_max = "maxtemperature/"
    folder_min = "mintemperature/"
    folder_pre = "predaily/"
  }
}

#Cloud Scheduler
resource "google_cloud_scheduler_job" "JobDownloadDataJMA" {
  name        = "JobDownloadDataJMA"
  project     = var.project_id
  schedule    = "47 13 * * *"
  description = "CF:DownloadDataJMAを実行"
  time_zone   = "Asia/Tokyo"

  pubsub_target {
    topic_name = google_pubsub_topic.TopicDownloadDataJMA.id
    data       = base64encode("test")
  }
}

#Cloud Pub/Sub
resource "google_pubsub_topic" "TopicDownloadDataJMA" {
  name    = "TopicDownloadDataJMA"
  project = var.project_id
}

#Cloud Storage
resource "google_storage_bucket" "download_file_jma" {
  name                     = "download_file_jma"
  project                  = var.project_id
  location                 = "asia-northeast1"
  force_destroy            = true
  public_access_prevention = "enforced"
}

resource "google_storage_bucket_object" "download_file_jma_folder" {
  for_each = local.cs_foldernames
  name     = each.value
  content  = " "
  bucket   = google_storage_bucket.download_file_jma.id
}

#CloudFunctions
resource "google_storage_bucket" "functions_bucket" {
  name                     = "pgm_sourcecode"
  project                  = var.project_id
  location                 = "asia-northeast1"
  force_destroy            = true
  public_access_prevention = "enforced"
}

##DownloadDataJMA
##PGM
resource "google_storage_bucket_object" "cf_packages_DownloadDataJMA" {
  name   = "DownloadDataJMA.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = data.archive_file.zip_DownloadDataJMA.output_path
}

data "archive_file" "zip_DownloadDataJMA" {
  type        = "zip"
  source_dir  = "./CloudFunctions/DownloadDataJMA"
  output_path = "./CloudFunctions/DownloadDataJMA/DownloadDataJMA.zip"
}

##Functionsの設定
resource "google_cloudfunctions2_function" "DownloadDataJMA" {
  name     = "DownloadDataJMA"
  project  = var.project_id
  location = "asia-northeast1"
  build_config {
    runtime     = "python312"
    entry_point = "DownloadDataJMA"
    source {
      storage_source {
        bucket = google_storage_bucket.functions_bucket.name
        object = google_storage_bucket_object.cf_packages_DownloadDataJMA.name
      }
    }
  }
  service_config {
    environment_variables = {
      TZ = "Asia/Tokyo"
    }
  }
  event_trigger {
    trigger_region = "asia-northeast1"
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
    pubsub_topic   = google_pubsub_topic.TopicDownloadDataJMA.id
  }
}

##DataTransImportBqDwhMaxtemJMA
##PGM
resource "google_storage_bucket_object" "cf_packages_DataTransImportBqDwhMaxtemJMA" {
  name   = "DataTransImportBqDwhMaxtemJMA.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = data.archive_file.zip_DataTransImportBqDwhMaxtemJMA.output_path
}

##PGM
data "archive_file" "zip_DataTransImportBqDwhMaxtemJMA" {
  type        = "zip"
  source_dir  = "./CloudFunctions/DataTransImportBqDwhMaxtemJMA"
  output_path = "./CloudFunctions/DataTransImportBqDwhMaxtemJMA/DataTransImportBqDwhMaxtemJMA.zip"
}

##Functionsの設定
resource "google_cloudfunctions2_function" "DataTransImportBqDwhMaxtemJMA" {
  name     = "DataTransImportBqDwhMaxtemJMA"
  project  = var.project_id
  location = "asia-northeast1"
  build_config {
    runtime     = "python312"
    entry_point = "DataTransImportBqDwhMaxtemJMA"
    source {
      storage_source {
        bucket = google_storage_bucket.functions_bucket.name
        object = google_storage_bucket_object.cf_packages_DataTransImportBqDwhMaxtemJMA.name
      }
    }
  }
  service_config {
    environment_variables = {
      TZ = "Asia/Tokyo"
    }
  }
  event_trigger {
    trigger_region = "asia-northeast1"
    event_type     = "google.cloud.audit.log.v1.written"
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
    event_filters {
      attribute = "serviceName"
      value     = "storage.googleapis.com"
    }
    event_filters {
      attribute = "methodName"
      value     = "storage.objects.create"
    }
    event_filters {
      attribute = "resourceName"
      value     = "projects/_/buckets/download_file_jma/objects/maxtemperature/*.csv"
      operator  = "match-path-pattern"
    }
  }
}