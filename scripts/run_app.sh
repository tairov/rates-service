export FLASK_APP=./src/service.py
export FLASK_ENV=development
export LISTEN_HOST=0.0.0.0
export LISTEN_PORT=5000
export PYTHONPATH=./src/
pipenv run flask run --host $LISTEN_HOST --port $LISTEN_PORT
