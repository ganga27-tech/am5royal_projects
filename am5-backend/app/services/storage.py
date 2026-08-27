import boto3
from app.core.config import settings
from typing import BinaryIO

class StorageService:
    def __init__(self):
        self.s3 = boto3.client(
            "s3",
            aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
            aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
            region_name=settings.AWS_REGION
        )
        self.bucket = settings.AWS_S3_BUCKET

    async def upload_file(self, file: BinaryIO, filename: str) -> str:
        if not self.bucket:
            # Fallback to local storage or raise error in production
            return f"/local-storage/{filename}"
        
        self.s3.upload_fileobj(file, self.bucket, filename)
        return f"https://{self.bucket}.s3.{settings.AWS_REGION}.amazonaws.com/{filename}"

storage_service = StorageService()
