FROM astrocrpublic.azurecr.io/runtime:3.0-4

# replace dbt-postgres with another supported adapter if you're using a different warehouse type
RUN python -m venv dbt_venv && source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-core dbt-postgres && deactivate