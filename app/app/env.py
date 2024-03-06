import json
from typing import Optional, Dict
from functools import lru_cache
from pydantic_settings import BaseSettings
from pydantic import BaseModel
import boto3

class DbSecret(BaseModel):
    db_user: str
    db_password: str
    db_host: str
    db_port: int

class Environment(BaseSettings):
    django_debug_mode: bool = False
    stage: str
    db_name: str
    db_secret_name: str
    aws_region: str = "ap-northeast-1"
    aws_endpoint_url: Optional[str] = None

    def get_secret(self, secret_name: str) -> Dict[str, str]:
        client = boto3.client(
            service_name='secretsmanager',
            region_name=self.aws_region,
            endpoint_url=self.aws_endpoint_url
        )
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        return json.loads(get_secret_value_response['SecretString'])

    # secrets managerからDBの接続情報を取得
    def get_db_secret(self) -> DbSecret:
        secret = self.get_secret(self.db_secret_name)
        return DbSecret.model_validate(secret)

@lru_cache
def get_env() -> Environment:
    return Environment()
