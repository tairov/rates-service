## Infrastructure as Code design decision

The main design decision in this Terraform project was to split the infrastructure into modules and use Terraform
workspaces to manage different environments. This allows for easier management of resources and separation of
environments during development.
Using modules in this way makes it easier to add, update, and remove services, because an engineer can do so by
maintaining only a couple of files in a single place - main.tf and <ENV>.tfvars rather than having to search through the
huge single main.tf. It also makes the code more organized, easier to understand, simpler to refactor, since we
eliminated code/logic duplication.

Using modules in this way makes it easier to add, update, and remove services, because an engineer can do so by
maintaining only a couple of files in a single place - `main.tf` and `<ENV>.tfvars` rather than having to search through
the huge single `main.tf`. It also makes the code more organized, easier to understand, simpler to refactor, since we
eliminated code/logic duplication.

### Using Terraform Workspaces for Development and Github Actions based CI/CD

Terraform workspaces allow for the creation of separate environments within a single configuration. This is useful for
development as it allows for easy testing of changes without affecting other environments. It also allows for the
creation of specific environments for different stages of the CI/CD pipeline, such as development, staging, and
production.

Essentially we have 2 types of CI/CD pipelines.

1. CI/CD for the infra code (Terraform, ansible, etc.)
2. CI/CD for the apps & services

In both cases the refactored modules repository could be nicely integrated into the pipelines.

#### CI/CD for the client service

See: [build-and-deploy.yml](.github%2Fworkflows%2Fbuild-and-deploy.yml)

Build pipeline is implemented in the github actions script. It contains the following steps:

* notify
* build-and-push-image

#### CI/CD for the Terraform infra

See: [infra-update.yml](.github%2Fworkflows%2Finfra-update.yml)

I've implemented ready to use github actions script. Beside basic liniting & setup steps it also contains the following
which must convey the idea I'm proposing:

`Comment terraform plan` - that is executed when **Pull Reqeust** created with changes under `tf/*` path.
It creates a comment within Pull Request that will show the implied changes implemented in the commits.
This will only work if TF state is stored somehwere remotely like in AWS-S3 or in Terraform Cloud.

`Terraform Apply` - if PR merged then this step will apply all changes on infra

If the changes are successful in the staging environment, they can then be promoted to the production environment by
merging the staging branch into the production branch and running Terraform in the production workspace.



## Application: Rest API for BTC rates retrieval

### Authentication

HTTP authentication is required to access endpoints. The login and password can be provided through a `.env` file.

### Endpoints:

1. `/rate/<currency>` - Returns a JSON response with the current BTC rate for the requested currency.

2. `/health` - Returns a JSON status of the service.

3. `/metrics` - Returns metrics in plain text format supported by Prometheus.

### Terraform setup

Before running `terraform init`, create a bucket for TF state:

```
aws s3 mb s3://rates-service-terraform-state-bucket
```

Also, create a DynamoDB table to enable state locking:

```
aws dynamodb create-table --table-name rates-service-terraform-state-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Infra update

If a pull request is created to update the infrastructure (currently all files under the `deploy/` directory), a separate GitHub Actions workflow will create a comment in the PR with the Terraform plan. Once the PR is merged, Terraform will be executed with the `apply -auto-approve` options.

### Package available on GitHub Container Registry

https://github.com/tairov/rates-service/pkgs/container/rates-service

### Production usage

For simplicity, a WSGI server like `waitress` is not used in development. For production, it is recommended to execute the Flask application through `waitress-serve`.

#### Running via Docker

To run the service using Docker, execute the following command:

```bash
docker run --name rates_service -p 8085:8085 \
  --env FLASK_ENV=development \
  --env LISTEN_HOST=0.0.0.0 \
  --env LISTEN_PORT=8085 \
  ghcr.io/tairov/rates-service:master
```

After running the Docker container, you can check if the service is up and running by visiting:

```bash
curl http://localhost:8085/health
```

To retrieve a JSON response for BTC/USD, use the following command:

```bash
curl -u "john:hello" http://localhost:8085/rate/USD
```

Please note that the authentication credentials (`john:hello`) should match the ones provided in the `.env` file to access the endpoints.

