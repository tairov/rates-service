export FLASK_APP=./src/service.py
export FLASK_ENV=development
export PYTHONPATH=./src/
pipenv run pytest
