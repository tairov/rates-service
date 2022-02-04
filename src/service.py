"""
webservice for REST API
"""

from flask import Flask
from flask_httpauth import HTTPBasicAuth
from flask import jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from dataprovider import DataProvider
from dotenv import dotenv_values
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from prometheus_client import make_wsgi_app
from metrics import stats
import os
import logging


def create_app():
    app = Flask(__name__)
    return app


app = create_app()

auth = HTTPBasicAuth()

config = dotenv_values('.env')

users = {
    config['auth_login']: generate_password_hash(config['auth_password']),
}

# default environment is `dev`
ENVIRONMENT = os.getenv('FLASK_ENV', 'development')

DEBUG_MODE = ENVIRONMENT == 'development'

format = '[%(asctime)s] %(levelname)s %(message)s'
logging.basicConfig(format=format, level=logging.INFO,
                    datefmt="%H:%M:%S")


@auth.verify_password
def verify_password(username, password):
    if username in users and \
            check_password_hash(users.get(username), password):
        return username


@app.route('/rate/<currency>', methods=['GET'])
@auth.login_required
def get_rate(currency):
    logging.info(f"get_rate request for currency {currency}")
    stats.inc('requests')
    dp = DataProvider(config)

    try:
        result = dp.get_rate(currency)
    except Exception as ex:
        stats.inc('exceptions')
        return jsonify({'error_msg': str(ex)})

    if result.get('error'):
        stats.inc('errors')
        return result

    response = jsonify({'base': result['data']['base'], 'currency': currency, 'rate': result['data']['amount']})
    return response


@app.route('/health')
def health():
    return jsonify({'status': 'running'})


# Add prometheus wsgi middleware to route /metrics requests
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

