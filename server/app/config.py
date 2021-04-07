import os
from dotenv import load_dotenv

load_dotenv()

# to make transfer to heroku smoother
dburl = os.environ.get("CLEARDB_DATABASE_URL")

class Config:

    DB_CONN_INFO = {
        "database": os.environ.get("DB_NAME") or "",
        "user": os.environ.get("DB_USER") or "",
        "password": os.environ.get("DB_PASSWORD") or "",
        "host":os.environ.get("DB_HOST") or "",
        "port": int(os.environ.get("DB_PORT")) or 3307
    }

    DB_URL = dburl