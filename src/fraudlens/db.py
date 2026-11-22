import os

import pyodbc
from dotenv import load_dotenv

load_dotenv()


def get_connection():
    """Open a connection to the local SQL Server using Windows authentication."""
    server = os.getenv("SQL_SERVER", "localhost")
    database = os.getenv("SQL_DATABASE", "master")
    driver = os.getenv("SQL_DRIVER", "ODBC Driver 18 for SQL Server")

    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )
    return pyodbc.connect(conn_str)
