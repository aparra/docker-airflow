# VERSION 1.9.0-2
# AUTHOR: Matthieu "Puckel_" Roisil
# DESCRIPTION: Airflow container
# BUILD: docker build --rm .
# SOURCE: https://github.com/iyesin/docker-airflow

FROM python:3.6-slim-stretch
MAINTAINER iyesin

# Airflow
ARG AIRFLOW_VERSION=1.9.0
ARG AIRFLOW_HOME=/usr/local/airflow

# Never prompts the user for choices on installation/configuration of packages
# US English as default language
ENV \
    DEBIAN_FRONTEND=noninteractive \
    TERM=linux \
    LANGUAGE=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LC_CTYPE=en_US.UTF-8 \
    LC_MESSAGES=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        default-libmysqlclient-dev \
        git \
    ' \
    && apt update -yqq \
    && apt install -yqq --no-install-recommends \
        $buildDeps \
        libmariadbclient?? \
        python3-pip \
        python3-requests \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && python -m pip install -U pip setuptools wheel \
        Cython \
        pytz \
        pyOpenSSL \
        ndg-httpsclient \
        pyasn1 \
        apache-airflow[crypto,celery,postgres,mysql,password,hive,jdbc]==$AIRFLOW_VERSION \
        celery[redis]==4.0.2 \
        boto \
        boto3 \
        pymysql \
        mysqlclient \
        PyAthenaJDBC \
        eventlet \
        kafka \
        apiclient==1.0.3 \
        google-api-python-client==1.5.5 \
        pandas==0.19.2 \
        pandas-gbq==0.1.6 \
        simple-salesforce==0.73.0 \
        slackclient==1.0.5 \
        pysftp \
        filechunkio \
        prometheus_client \
    && apt purge --purge --auto-remove -yqq $buildDeps \
    && apt-get clean \
    && rm -rf \
        /root/.cache \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /var/cache/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
