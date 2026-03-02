#!/usr/bin/env sh
set -eu

if [ -z "${APP_KEY:-}" ]; then
  export APP_KEY="$(php artisan key:generate --show --no-interaction)"
  echo "APP_KEY was not set. Generated an ephemeral APP_KEY for this container."
fi

php artisan config:clear || true

attempt=1
max_attempts=20
until php artisan migrate --force; do
  if [ "$attempt" -ge "$max_attempts" ]; then
    echo "Database is still not ready after $max_attempts attempts."
    exit 1
  fi
  echo "Database not ready (attempt $attempt/$max_attempts). Retrying in 5 seconds..."
  attempt=$((attempt + 1))
  sleep 5
done

php artisan storage:link || true

exec php artisan serve --host=0.0.0.0 --port="${PORT:-10000}"
