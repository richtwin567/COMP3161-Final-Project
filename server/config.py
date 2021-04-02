import os
from dotenv import load_dotenv

load_dotenv()

# to make transfer to heroku smoother
dburl = os.environ.get("CLEARDB_DATABASE_URL")

database_end= dburl.find("://")
user_end = dburl.find(":",database_end+1)
password_end = dburl.find("@", user_end+1)
host_end = dburl.find("/", password_end+1)
dbname_end = dburl.find("?", host_end+1) or len(dburl)

database = dburl[:database_end]
user = dburl[database_end+1:user_end]
password = dburl[user_end+1:password_end]
host = dburl[password_end+1:host_end]
dbname = dburl[host_end+1:dbname_end]

class Config:

    DB_CONN_INFO = {
        "dbname": dbname,
        "database": database,
        "user": user,
        "password": password,
        "host":host
    }