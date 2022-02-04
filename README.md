# rates-service example
Rest API for rates retrieval

### Authetication

http authentication required to access endpoints login/password could be provided through `.env` file

### Endpoints:

`/rate/<currency>` - returns JSON response with current BTC rate for requested currency

`/health` - returns JSON status of the service

`/metrics` - returns metrics in plain text format supported by Prometheus

### Production usage
for simplicity I don't use WSGI server like `waitress` for production it's better to execute flask application through `waitress-serve`
