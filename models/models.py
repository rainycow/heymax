# user
# user_id, country, other user attributes like email etc.

# event
# event_time, user_id, event_type, transaction_category, miles_amount, platform, utm_source

from sqlalchemy import Column, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.dialects import postgresql
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.schema import CreateTable

Base = declarative_base()


# User dimension table
class User(Base):
    __tablename__ = "dim_users"

    user_id = Column(String, primary_key=True)
    country = Column(String)
    # 1 user -> many events
    events = relationship("Event", back_populates="dim_user")


# Events fact table
class Event(Base):
    __tablename__ = "fact_events"

    event_id = Column(Integer, primary_key=True, autoincrement=True)
    event_time = Column(DateTime)
    user_id = Column(String, ForeignKey("dim_users.user_id"))
    event_type = Column(String)
    transaction_category = Column(String)
    miles_amount = Column(Float)
    platform = Column(String)
    utm_source = Column(String)
    # 1 event -> 1 user
    user = relationship("User", back_populates="fact_events")


if __name__ == "__main__":
    for table in Base.metadata.sorted_tables:
        table = CreateTable(table).compile(dialect=postgresql.dialect())
        print(table)
