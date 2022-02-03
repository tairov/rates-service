"""
webservice for REST API
"""

from flask import Flask, abort, Response
from flask_httpauth import HTTPBasicAuth
from flask import jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from dataprovider import DataProvider
from dotenv import dotenv_values
from werkzeug.middleware.dispatcher import DispatcherMiddleware
from prometheus_client import make_wsgi_app, Counter
import logging

app = Flask(__name__)
auth = HTTPBasicAuth()

users = {
    "john": generate_password_hash("hello"),
}

config = dotenv_values(".env")

DEBUG_MODE = config['ENVIRONMENT'] == 'dev'

format = '[%(asctime)s] %(levelname)s %(message)s'
logging.basicConfig(format=format, level=logging.INFO,
                    datefmt="%H:%M:%S")


class Metrics:
    def __init__(self):
        self.counters = {
            'requests': Counter('requests', 'Requests count'),
            'exceptions': Counter('exceptions', 'Exceptions count'),
            'errors': Counter('errors', 'Errors count')
        }

    def inc(self, counter):
        if counter not in self.counters:
            return
        self.counters[counter].inc()

stats = Metrics()

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
        return jsonify({'error_msg': result['error']})

    response = jsonify({'base': result['data']['base'], 'currency': currency, 'rate': result['data']['amount']})
    return response


@app.route('/health')
def health():
    return jsonify({'status': 'running'})


# Add prometheus wsgi middleware to route /metrics requests
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})

if __name__ == '__main__':
    app.run(debug=DEBUG_MODE)
