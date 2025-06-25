FROM astrocrpublic.azurecr.io/runtime:3.0-4

# Install git
USER root
RUN apt-get update && apt-get install -y git curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    node -v && npm -v

USER astro
# Your existing dbt setup
RUN python -m venv dbt_venv && \
    source dbt_venv/bin/activate && \
    pip install --no-cache-dir dbt-core dbt-postgres && \
    deactivate


