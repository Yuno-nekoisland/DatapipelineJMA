import functions_framework
import requests
import logging
from google.cloud import storage
import google.cloud.logging
from datetime import datetime

# Register an HTTP function with the Functions Framework
@functions_framework.http
def DownloadDataJMA(request):
    # 標準 Logger の設定
    logging.basicConfig(
            format = "[%(asctime)s][%(levelname)s] %(message)s",
            level = logging.DEBUG
        )
    logger = logging.getLogger()

    # Cloud Logging ハンドラを logger に接続
    logging_client = google.cloud.logging.Client()
    logging_client.setup_logging()

    # setup_logging() するとログレベルが INFO になるので DEBUG に変更
    logger.setLevel(logging.DEBUG)

    # Cloud Storageクライアントの初期化
    storage_client = storage.Client()

    # Cloud Storageのバケット名と保存するファイルの名前
    bucket_name = "download_file_jma"

    # Cloud Storageのバケットを取得
    bucket = storage_client.bucket(bucket_name)

    # ダウンロードするファイルの情報
    files_to_download = [
        {"url": "https://www.data.jma.go.jp/stats/data/mdrr/tem_rct/alltable/mxtemsadext00_rct.csv", "file_name": "mxtemsadext00_rct.csv", "folder_name": "maxtemperature", "content_type": "text/csv"},
        {"url": "https://www.data.jma.go.jp/stats/data/mdrr/tem_rct/alltable/mntemsadext00_rct.csv", "file_name": "mntemsadext00_rct.csv", "folder_name": "mintemperature", "content_type": "text/csv"},
        {"url": "https://www.data.jma.go.jp/stats/data/mdrr/pre_rct/alltable/predaily00_rct.csv", "file_name": "predaily00_rct.csv", "folder_name": "predaily", "content_type": "text/csv"}
    ]

    # ファイルをダウンロードしてCloud Storageにアップロード
    for file_info in files_to_download:
        try:
            # 現在の日付を取得し、ファイル名の接頭辞とする
            current_date = datetime.now().strftime("%Y-%m-%d")

            # ファイルをダウンロード
            response = requests.get(file_info["url"])
            response.raise_for_status()

            # SJISからUTF-8に変換
            content_utf8 = response.content.decode('shift-jis').encode('utf-8')

            # ファイル名にフォルダ名と当日日付を含める
            current_file = f"{file_info['folder_name']}/{current_date}_{file_info['file_name']}"

            # Cloud Storageにアップロード
            blob = bucket.blob(current_file)
            blob.upload_from_string(content_utf8, content_type=file_info["content_type"])

            logger.info(f"File uploaded to Cloud Storage at gs://{bucket_name}/{current_file}")

        except requests.exceptions.RequestException as e:
            logger.error(f"Error downloading file: {e}")
        except Exception as e:
            logger.error(f"Error uploading file to Cloud Storage: {e}")

    return "OK"
