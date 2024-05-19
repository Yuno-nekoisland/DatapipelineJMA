##dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id    = "datasetJMA"
  friendly_name = "datasetJMA"
  description   = "気象庁のcsvデータを格納する。"
  location      = "asia-northeast1"
}

##table
##dwhMaxtemJMA
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

  schema = <<EOF
[
  {
    "name": "observatoryNo",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "観測所番号"
  },
  {
    "name": "prefectures",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "都道府県"
  },
  {
    "name": "spot",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "地点"
  },
  {
    "name": "maxTemp",
    "type": "FLOAT",
    "mode": "REQUIRED",
    "description": "当日の最高気温(℃)"
  },
  {
    "name": "diffAveYear",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "平年差（℃）"
  },
  {
    "name": "diffPreDay",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "前日差（℃）"
  },
  {
    "name": "currentTimeYMD",
    "type": "DATE",
    "mode": "REQUIRED",
    "description": "現在時刻(年月日)"
  }
]
EOF

}

##dwhMintemJMA
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

  schema = <<EOF
[
  {
    "name": "observatoryNo",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "観測所番号"
  },
  {
    "name": "prefectures",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "都道府県"
  },
  {
    "name": "spot",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "地点"
  },
  {
    "name": "minTemp",
    "type": "FLOAT",
    "mode": "REQUIRED",
    "description": "当日の最低気温(℃)"
  },
  {
    "name": "diffAveYear",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "平年差（℃）"
  },
  {
    "name": "diffPreDay",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "前日差（℃）"
  },
  {
    "name": "currentTimeYMD",
    "type": "DATE",
    "mode": "REQUIRED",
    "description": "現在時刻(年月日)"
  }
]
EOF

}

##dwhPredailyJMA
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

  schema = <<EOF
[
  {
    "name": "observatoryNo",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "観測所番号"
  },
  {
    "name": "prefectures",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "都道府県"
  },
  {
    "name": "spot",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "地点"
  },
  {
    "name": "precipitation",
    "type": "FLOAT",
    "mode": "REQUIRED",
    "description": "当日の値(mm)"
  },
  {
    "name": "monthlyNormalRatio",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "月平年比(%)"
  },
  {
    "name": "diffAveYear",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "月平年値"
  },
  {
    "name": "currentTimeYMD",
    "type": "DATE",
    "mode": "REQUIRED",
    "description": "現在時刻(年月日)"
  }
]
EOF

}