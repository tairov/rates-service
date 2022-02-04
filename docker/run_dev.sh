#!/usr/bin/env sh

docker run --name rates_service -p 5000:5000 \
  --env FLASK_ENV=development \
  --env LISTEN_HOST=0.0.0.0 \
  --env LISTEN_PORT=5000 \
  rates-app:1.0
