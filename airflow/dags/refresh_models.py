"""
### Run a dbt Core project as a task group with Cosmos
"""

import os
import uuid
from datetime import timedelta

from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.sdk import Variable, dag
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

REPO_DIR = "/tmp/heymax"
EVIDENCE_DIR = f"{REPO_DIR}/reports"
GH_PAGES_BRANCH = "gh-pages"


def generate_uuid(**context):
    new_uuid = str(uuid.uuid4())
    context["ti"].xcom_push(key="event_uuid", value=new_uuid)


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
    # use airflow Variable to mask access token in logs
    gh_token = Variable.get("access_token")
    gen_uuid = PythonOperator(
        task_id="generate_uuid",
        python_callable=generate_uuid,
    )
    transform_data = DbtTaskGroup(
        group_id="transform_data",
        project_config=ProjectConfig(DBT_PROJECT_PATH),
        profile_config=profile_config,
        execution_config=execution_config,
        default_args={"retries": 2},
        operator_args={
            "vars": {
                "event_uuid": "{{ ti.xcom_pull(task_ids='generate_uuid', "
                "key='event_uuid') }}"
            }
        },
    )

    clone_repo_and_build = BashOperator(
        task_id="clone_repo_and_build",
        bash_command=f"""
        rm -rf {REPO_DIR}
        git clone https://{gh_token}@github.com/rainycow/heymax.git {REPO_DIR}
        cd {REPO_DIR}
        git checkout feat/refresh-evidence
        cd {EVIDENCE_DIR}
        npm ci
        npm run sources
        npm run build

        mkdir -p /tmp/build
        cp -r {EVIDENCE_DIR}/build/* /tmp/build/

        # checkout gh-pages branch
        git checkout {GH_PAGES_BRANCH} 2>/dev/null || git checkout -b {GH_PAGES_BRANCH}

        find . -mindepth 1 ! -regex '^./\.git\(/.*\)?' -exec rm -rf {{}} + > /dev/null 2>&1

        cp -r /tmp/build/* .
        """,
    )

    push_to_gh_pages = BashOperator(
        task_id="install_dependencies",
        bash_command=f"""
        cd {EVIDENCE_DIR}
        git checkout {GH_PAGES_BRANCH}
        touch .nojekyll
        git config user.email "airflow@bot.com"
        git config user.name "airflow"
        git add .
        git commit -m "Deploy updated Evidence BI"
        git remote set-url origin https://{gh_token}@github.com/rainycow/heymax.git
        git push origin {GH_PAGES_BRANCH} --force
        """,
    )

    (gen_uuid >> transform_data >> clone_repo_and_build >> push_to_gh_pages)


setup_db_using_dbt_dag()
