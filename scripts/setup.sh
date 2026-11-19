#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f .env ] || cp .env.example .env
if [ ! -f composer.lock ] || [ ! -f package-lock.json ]; then
    echo 'Faltan archivos lock. El profesor debe preparar y versionar la plantilla primero.' >&2
    exit 1
fi
docker compose build app
docker compose run --rm --no-deps app composer install --no-interaction --prefer-dist
if ! grep -q '^APP_KEY=base64:' .env; then
    docker compose run --rm --no-deps app php artisan key:generate
fi
docker compose up -d db
docker compose run --rm app php artisan migrate --seed --force
docker compose run --rm node npm ci
docker compose run --rm node npm run build
docker compose up -d app
echo 'Proyecto preparado. URL predeterminada: http://localhost:8080'
