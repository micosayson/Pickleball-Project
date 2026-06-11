from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.seeding import run_system_seeding
from app.db.session import SessionLocal


def main() -> None:
    db = SessionLocal()
    try:
        run_system_seeding(db)
        db.commit()
        print("Demo seed complete.")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()
