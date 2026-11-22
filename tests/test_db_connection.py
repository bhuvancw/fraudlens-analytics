from fraudlens.db import get_connection


def test_can_connect_to_sql_server():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT 1")
    assert cursor.fetchone()[0] == 1
    conn.close()
