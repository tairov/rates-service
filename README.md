# rates-service example
Rest API for rates retrieval

### Authetication

http authentication required to access endpoints login/password could be provided through `.env` file

### Endpoints:

`/rate/<currency>` - returns JSON response with current BTC rate for requested currency

`/health` - returns JSON status of the service

`/metrics` - returns metrics in plain text format supported by Prometheus

### Terraform setup

Bucket for TF state must be created before `terraform init`
`aws s3 mb s3://rates-service-terraform-state-bucket`
DynamoDB table must be created to enable state lock

```
aws dynamodb create-table --table-name rates-service-terraform-state-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```
### Infra update

If PR created to update infrastructure (currenty all files under deploy/** directory) , separate github actions workflow creates a comment in PR with terraform plan. Once PR merged terraform will be executed with `apply -auto-approve` options

### Production usage
for simplicity I don't use WSGI server like `waitress` for production it's better to execute flask application through `waitress-serve`

