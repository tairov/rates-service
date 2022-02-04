# https://pythonspeed.com/articles/pipenv-docker/
FROM python:3.9-slim-bullseye
RUN pip install pipenv
COPY Pipfile* /tmp
RUN cd /tmp && pipenv lock --keep-outdated --requirements > requirements.txt
RUN pip install -r /tmp/requirements.txt
COPY src/ /tmp/myapp
COPY .env /tmp/myapp/
ENV FLASK_APP=service
CMD cd /tmp/myapp/ && flask run --host $LISTEN_HOST --port $LISTEN_PORT
