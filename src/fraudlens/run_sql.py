import re
import sys
from pathlib import Path

from fraudlens.db import get_connection


def run_sql_file(path):
    """Run a .sql file, sending one batch at a time (batches are split on GO)."""
    sql = Path(path).read_text(encoding="utf-8")
    batches = re.split(r"^\s*GO\s*$", sql, flags=re.IGNORECASE | re.MULTILINE)

    conn = get_connection()
    conn.autocommit = True
    cursor = conn.cursor()

    for batch in batches:
        if not batch.strip():
            continue
        cursor.execute(batch)
        while True:
            if cursor.description:
                for row in cursor.fetchall():
                    print(tuple(row))
            if not cursor.nextset():
                break

    conn.close()


if __name__ == "__main__":
    run_sql_file(sys.argv[1])