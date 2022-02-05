from json import JSONDecodeError

from service import app, config
import dataprovider
import mock
from requests.auth import _basic_auth_str
from unittest.mock import patch

headers = {
    'Authorization': _basic_auth_str(config['auth_login'], config['auth_password'])
}

AVAILABLE_CURRENCY = 'USD'

UNKNOWN_CURRENCY = 'USDXX'

MOCK_SUCCESS_RESPONSE = {"data": {"base": "BTC", "currency": "USD", "amount": "40532.08"}}
MOCK_UNKNOWN_CURRENCY_RESPONSE = {"errors": [{"id": "invalid_request", "message": "Currency is invalid"}]}
MOCK_CORRUPTED_JSON = '{"data": {"base": "BTC"'


def test_health_success():
    with app.test_client() as test_client:
        response = test_client.get(f'/health')
        assert response.status_code == 200


def test_metrics_success():
    with app.test_client() as test_client:
        response = test_client.get(f'/metrics')
        assert b'requests_total' in response.data
        assert response.status_code == 200


@patch.object(dataprovider.requests.Session, 'get')
def test_get_rate_success(mock_get):
    mock_get.return_value.json = mock.Mock(return_value=MOCK_SUCCESS_RESPONSE)
    with app.test_client() as test_client:
        response = test_client.get(f'/rate/{AVAILABLE_CURRENCY}', headers=headers)
        mock_get.assert_called()
        assert response.json['rate'] == MOCK_SUCCESS_RESPONSE['data']['amount']
        assert response.json['currency'] == MOCK_SUCCESS_RESPONSE['data']['currency']
        assert response.status_code == 200


@patch.object(dataprovider.requests.Session, 'get')
def test_get_rate_unknown_currency(mock_get):
    mock_get.return_value.json = mock.Mock(return_value=MOCK_UNKNOWN_CURRENCY_RESPONSE)
    with app.test_client() as test_client:
        response = test_client.get(f'/rate/{UNKNOWN_CURRENCY}', headers=headers)
        assert 'error_msg' in response.json
        assert response.json['error'] == MOCK_UNKNOWN_CURRENCY_RESPONSE['errors'][0]['id']
        assert response.json['error_msg'] == MOCK_UNKNOWN_CURRENCY_RESPONSE['errors'][0]['message']


@patch.object(dataprovider.requests.Session, 'get')
def test_get_rate_corrupted_response(mock_get):
    mock_get.return_value.json.side_effect = JSONDecodeError('Decode error', '', 0)
    with app.test_client() as test_client:
        response = test_client.get(f'/rate/{AVAILABLE_CURRENCY}', headers=headers)
        assert 'error_msg' in response.json
        assert response.json['error_msg'] == 'json decode error'
        assert False
