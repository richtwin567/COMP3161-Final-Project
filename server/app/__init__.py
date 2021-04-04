from flask import Flask
from .config import Config
from mysql.connector import connect

app = Flask(__name__)

app.config.from_object(Config)

conn = connect(**app.config.get("DB_CONN_INFO"))

cur = conn.cursor(dictionary=True)
