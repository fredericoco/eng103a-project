ARG APP_IMAGE=debian:11.2-slim

FROM $APP_IMAGE AS base

FROM base
ENV FLASK_APP app.py
WORKDIR /project
ADD . /project

RUN apt-get update && apt-get -y dist-upgrade

RUN apt-get -y install apt-utils \
    build-essential \
    python3 \
    gcc \
    python3-dev \
    python3-pip \
    python3-numpy \
    python3-pandas

COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN pip install 

EXPOSE 5000

ENTRYPOINT ["python3", "-m", "flask", "run", "--host=0.0.0.0"]