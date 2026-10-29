
from pathlib import Path

import duckdb


# Resolve paths relative to this script's location.
PROJECT_DIR = Path(__file__).resolve().parents[1]
REPO_DIR = PROJECT_DIR.parent
DATABASE_PATH = REPO_DIR / "dev.duckdb"
OUTPUT_DIR = REPO_DIR / "deliverables"

REPORTS = [
    "monthly_team_sales",
    "monthly_team_revenue_rolling",
    "quarterly_top_accounts",
]


def main():
    if not DATABASE_PATH.exists():
        raise FileNotFoundError(
            f"DuckDB database not found: {DATABASE_PATH}"
        )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    connection = duckdb.connect(str(DATABASE_PATH), read_only=True)

    try:
        available_tables = {
            row[0]
            for row in connection.execute("SHOW TABLES").fetchall()
        }

        for report in REPORTS:
            if report not in available_tables:
                raise ValueError(
                    f"Report table '{report}' not found in {DATABASE_PATH}"
                )

            output_path = OUTPUT_DIR / f"{report}.csv"
            escaped_path = output_path.as_posix().replace("'", "''")

            connection.execute(
                f"COPY (SELECT * FROM {report} ORDER BY ALL) "
                f"TO '{escaped_path}' (HEADER, DELIMITER ',')"
            )

            print(f"Exported {report} -> {output_path}")

    finally:
        connection.close()


if __name__ == "__main__":
    main()
