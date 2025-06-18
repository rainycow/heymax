FROM python:3.12-slim

# Set up venv
ENV VENV_PATH=/opt/venv
ENV PATH="$VENV_PATH/bin:$PATH"

RUN apt-get update && apt-get install -y python3-venv build-essential libpq-dev
RUN python3 -m venv $VENV_PATH

# Install Python requirements
COPY requirements.txt /
RUN pip install --upgrade pip && pip install -r /requirements.txt

# Copy code
COPY /db /app
COPY /dbt/models /app/models
WORKDIR /app

# Run your script to populate Postgres
CMD ["sh", "-c", "sleep 5 && python db_setup.py"]
