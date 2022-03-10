FROM python:3.7-slim AS compile-image
RUN apt-get update -y && apt-get install -y --no-install-recommends build-essential gcc && python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /project
COPY . /project
RUN pip install -r requirements.txt

FROM python:3.7-slim
COPY --from=compile-image /opt/venv /opt/venv
COPY --from=compile-image /project /project
ENV PATH="/opt/venv/bin:$PATH"
ENV FLASK_APP=app.py
WORKDIR /project
CMD cd /project && flask run -h 0.0.0.0