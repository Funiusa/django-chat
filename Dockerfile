FROM python:3.9-slim-buster

LABEL authors="denis"

EXPOSE 8000

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
        apt-transport-https \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        less \
        libpcre3 \
        libpcre3-dev \
        openssh-client \
        telnet \
        unzip \
        vim \
        wget \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/* \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && truncate -s 0 /var/log/*log

RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=$HOME/.poetry/ python3 -

ENV PATH $PATH:/root/.poetry/bin

RUN poetry config virtualenvs.create false

COPY scripts/wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/wait-for-it.sh

RUN mkdir -p /app

WORKDIR /app

COPY ./chat/ app/
COPY ./chat/pyproject.toml ./chat/config.toml ./

RUN poetry install  --no-interaction --no-ansi

ENV DJANGO_SETTINGS_MODULE="chat.settings"

CMD wait-for-it.sh db:5432 -- python manage.py runserver 0.0.0.0:8000

