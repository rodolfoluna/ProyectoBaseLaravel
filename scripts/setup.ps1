$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Invoke-Docker {
    & docker @args
    if ($LASTEXITCODE -ne 0) { throw "Docker falló: docker $args" }
}
if (!(Test-Path .env)) { Copy-Item .env.example .env }
if (!(Test-Path composer.lock) -or !(Test-Path package-lock.json)) {
    throw 'Faltan archivos lock. El profesor debe ejecutar primero scripts/prepare-template.ps1.'
}
Invoke-Docker compose build app
Invoke-Docker compose run --rm --no-deps app composer install --no-interaction --prefer-dist
$key = Select-String -Path .env -Pattern '^APP_KEY=base64:' -Quiet
if (!$key) { Invoke-Docker compose run --rm --no-deps app php artisan key:generate }
Invoke-Docker compose up -d db
Invoke-Docker compose run --rm app php artisan migrate --seed --force
Invoke-Docker compose run --rm node npm ci
Invoke-Docker compose run --rm node npm run build
Invoke-Docker compose up -d app
Write-Host 'Proyecto preparado. URL predeterminada: http://localhost:8080'
