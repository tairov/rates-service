from service import app, config
from requests.auth import _basic_auth_str

headers = {
    'Authorization': _basic_auth_str(config['auth_login'], config['auth_password'])
}

AVAILABLE_CURRENCY = 'USD'

UNKNOWN_CURRENCY = 'USDXX'


def test_health_success():
    with app.test_client() as test_client:
        response = test_client.get(f'/health')
        assert response.status_code == 200


def test_get_rate_success():
    with app.test_client() as test_client:
        response = test_client.get(f'/rate/{AVAILABLE_CURRENCY}', headers=headers)
        assert response.status_code == 200


def test_get_rate_unknown_currency():
    with app.test_client() as test_client:
        response = test_client.get(f'/rate/{UNKNOWN_CURRENCY}', headers=headers)
        assert 'error_msg' in response.json
        assert response.json['error_msg'] == 'invalid_request'
        assert response.status_code == 200
