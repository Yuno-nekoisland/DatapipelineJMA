import functions_framework
import requests
import logging
from google.cloud import bigquery
from google.cloud import storage
import google.cloud.logging
from datetime import datetime
import pandas as pd

@functions_framework.http
def DataTransImportBqDwhMaxtemJMA(request):
    # 標準Loggerの設定
    logging.basicConfig(
            format = "[%(asctime)s][%(levelname)s] %(message)s",
            level = logging.DEBUG
        )
    logger = logging.getLogger()

    # Cloud Loggingハンドラをloggerに接続
    logging_client = google.cloud.logging.Client()
    logging_client.setup_logging()

    # setup_logging()するとログレベルがINFOになるのでDEBUGに変更
    logger.setLevel(logging.DEBUG)

    # BigQueryクライアントを初期化
    bq_client = bigquery.Client()

    # BigQueryテーブルの参照を作成
    dataset_id = "datasetJMA"
    table_id = "dwhMaxtemJMA"
    table_ref = f"{bq_client.project}.{dataset_id}.{table_id}"

    try:
        #実行日の日付を宣言する
        current_ymd = datetime.now().strftime("%Y-%m-%d")
        current_d = datetime.now().strftime("%d")

        # Cloud Storageからダウンロードするファイルのパス
        gcs_uri = f"gs://download_file_jma/maxtemperature/{current_ymd}_mxtemsadext00_rct.csv"

        # CSVをPandasDataFrameに読み込む
        df = pd.read_csv(gcs_uri, encoding="utf-8", header=0)
        df = df.filter(
                items=["観測所番号", "都道府県", "地点", "現在時刻(年)", "現在時刻(月)", "現在時刻(日)", f"{current_d}日の最高気温(℃)", "平年差（℃）", "前日差（℃）"]
                , axis='columns')

        #行を絞り込む
        filtered_df = df.query("観測所番号 in (62016,62046,62131)")
        logger.debug(filtered_df.shape)
        logger.debug(filtered_df)

        #現在時刻を列結合する
        filtered_df["現在時刻(年月日)"] = filtered_df["現在時刻(年)"].astype(str).str.cat([filtered_df["現在時刻(月)"].astype(str), filtered_df["現在時刻(日)"].astype(str)], sep="-")
        logger.debug(filtered_df.shape)
        filtered_df = filtered_df.drop(columns=["現在時刻(年)","現在時刻(月)","現在時刻(日)"])
        logger.debug(filtered_df.shape)

        # DataFrameをBigQueryに書き込む
        job_config = bigquery.LoadJobConfig(
            skip_leading_rows=0,
            source_format=bigquery.SourceFormat.CSV,
            write_disposition='WRITE_APPEND'
        )
        job = bq_client.load_table_from_dataframe(filtered_df, f"{table_ref}", job_config=job_config)

        # ジョブの完了を待つ
        job.result()

        logger.info(f"Selected columns imported into BigQuery table {dataset_id}.{table_id}")

    except Exception as e:
        logger.error(f"Error importing CSV to BigQuery: {e}")

    return "OK"
