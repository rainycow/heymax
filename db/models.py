from sqlalchemy import TIMESTAMP, Column, Date, Float, ForeignKey, String
from sqlalchemy.dialects import postgresql
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.schema import CreateTable

Base = declarative_base()


# User dimension table
class User(Base):
    __tablename__ = "dim_users"

    user_id = Column(String, primary_key=True)
    country = Column(String)
    # loaded_at = Column(Date, default="2025-06-01")
    # 1 user -> many events
    events = relationship("Event", back_populates="user")


# Events fact table
class Event(Base):
    __tablename__ = "fact_events"
    # surrogate key
    event_id = Column(String, primary_key=True)
    event_time = Column(TIMESTAMP)
    user_id = Column(String, ForeignKey("dim_users.user_id"))
    event_type = Column(String)
    transaction_category = Column(String)
    miles_amount = Column(Float)
    platform = Column(String)
    utm_source = Column(String)
    # loaded_at = Column(Date, default="2025-06-01")
    # 1 event -> 1 user
    user = relationship("User", back_populates="events")


if __name__ == "__main__":
    for table in Base.metadata.sorted_tables:
        table = CreateTable(table).compile(dialect=postgresql.dialect())
        print(table)
