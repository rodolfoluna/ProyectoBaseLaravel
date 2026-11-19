# Solo para el profesor: resolver dependencias una vez y versionar ambos lock.
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
function Invoke-Docker {
    & docker @args
    if ($LASTEXITCODE -ne 0) { throw "Docker falló: docker $args" }
}
if (!(Test-Path .env)) { Copy-Item .env.example .env }
Invoke-Docker compose build app
Invoke-Docker compose run --rm --no-deps app composer install --no-interaction --prefer-dist
if (Test-Path package-lock.json) {
    Invoke-Docker compose run --rm node npm ci
} else {
    Invoke-Docker compose run --rm node npm install
}
& "$PSScriptRoot/setup.ps1"
if ($LASTEXITCODE -ne 0) { throw 'No se completó la preparación.' }
