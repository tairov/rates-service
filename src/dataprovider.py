"""
Class for providing data for webservice
"""
from json import JSONDecodeError

import requests
from retry import retry

DELAY = 3
RETRIES = 3

class DataProvider:
    def __init__(self, config):
        self.session = requests.Session()
        self.base_url = config['base_url']
        self.user_agent = config['user_agent']

    def get_rate(self, currency):
        result = self.get_url(self.base_url.format(currency=currency))
        try:
            result = result.json()
        except (ValueError, JSONDecodeError) as ex:
            return {'error': 'value_error', 'error_msg': 'json decode error'}

        if result.get('errors', None) is not None:
            return {'error': result['errors'][0]['id'], 'error_msg': result['errors'][0]['message']}

        return result

    # retry request in case of it returned error
    @retry((requests.ConnectionError, requests.HTTPError), delay=DELAY, tries=RETRIES)
    def get_url(self, url):
        headers = {'user-agent': self.user_agent}
        return self.session.get(url, headers=headers)
