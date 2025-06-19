"""
### Run a dbt Core project as a task group with Cosmos
"""

import os
from datetime import timedelta

from airflow.sdk import dag
from cosmos import DbtTaskGroup, ExecutionConfig, ProfileConfig, ProjectConfig
from cosmos.profiles import PostgresUserPasswordProfileMapping

OWNER = "TY"
CONNECTION_ID = "test"
DB_NAME = "postgres"
USER = "postgres"
SCHEMA_NAME = "public"

# path to the dbt_project.yml
DBT_PROJECT_PATH = f"{os.environ['AIRFLOW_HOME']}/dags/dbt"
DBT_EXECUTABLE_PATH = f"{os.environ['AIRFLOW_HOME']}/dbt_venv/bin/dbt"

profile_config = ProfileConfig(
    profile_name="hm_metrics",
    target_name="dev",
    profile_mapping=PostgresUserPasswordProfileMapping(
        conn_id=CONNECTION_ID,
        profile_args={
            "database": DB_NAME,
            "schema": SCHEMA_NAME,
            "user": USER,
        },
    ),
)

execution_config = ExecutionConfig(
    dbt_executable_path=DBT_EXECUTABLE_PATH,
)
default_args = {
    "owner": "TY",
    "schedule": "@daily",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
}


@dag(default_args=default_args)
def setup_db_using_dbt_dag():
    transform_data = DbtTaskGroup(
        group_id="transform_data",
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        profile_config=profile_config,
        execution_config=execution_config,
        default_args={"retries": 2},
    )

    transform_data


setup_db_using_dbt_dag()
