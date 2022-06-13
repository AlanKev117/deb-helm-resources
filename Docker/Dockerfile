FROM apache/airflow

# Docker build args
ARG DAGS_DIR=${AIRFLOW_HOME}/dags
ARG ASSETS_DIR=${AIRFLOW_HOME}/assets

# Tweak image env vars
ENV AIRFLOW__CORE__LOAD_EXAMPLES=False
ENV ASSETS_DIR=${ASSETS_DIR}

# Install pip dependencies
RUN pip install --no-cache-dir pandas

# Add new directory for assets
RUN umask 002; mkdir ${ASSETS_DIR}

# Place assets within image
COPY --chown=airflow:root ./assets ${ASSETS_DIR}

# Place dags within image
COPY --chown=airflow:root ./dags ${DAGS_DIR}
