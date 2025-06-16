import logging
import os

import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session
from utils import load_config

from models import Base, Event, User

config = load_config("file.yaml")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)

logger = logging.getLogger(__name__)


DATABASE_URL = (
    f"postgresql+psycopg2://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

engine = create_engine(DATABASE_URL)
session = Session(bind=engine)

try:
    logger.info("Starting DB setup...")
    # generates the DDLs to run against the db, generate all the tables
    Base.metadata.create_all(engine)

    df = pd.read_csv(config["path"])
    # keep only unique user_id+country combi
    user_df = df[["user_id", "country"]].drop_duplicates()

    # Insert users
    user_records = []
    event_records = []

    for _, row in user_df.iterrows():
        user = {"user_id": row["user_id"], "country": row["country"]}
        user_records.append(user)

    for _, row in df.iterrows():
        event = {
            "event_time": row["event_time"],
            "event_type": row["event_type"],
            "user_id": row["user_id"],
            "transaction_category": row["transaction_category"],
            "miles_amount": row["miles_amount"],
            "platform": row["platform"],
            "utm_source": row["utm_source"],
        }
        event_records.append(event)

    session.execute(insert(User), user_records)
    session.execute(insert(Event), event_records)

    session.commit()
    session.close()
    logger.info("Successfully loaded data into the database.")

except Exception as e:
    logging.error(f"Unexpected error occured: {e}")
    session.rollback()

finally:
    session.close()
