# Proyecto Base Laravel

Plantilla docente: Laravel 12, PHP 8.4.14, MariaDB 11.4.9, Composer 2.8.12 y Node 22.21.1.
Entorno de desarrollo local. No es una configuración de producción.

## Estado de preparación

Validado el 19 de noviembre de 2026: Laravel 12.73.0, preparación completa en Docker, MariaDB saludable, tres migraciones aplicadas, compilación Vite correcta y respuesta HTTP 200. Pruebas: 3 aprobadas, 6 aserciones.

El código base proviene del esqueleto oficial laravel/laravel.
Las imágenes base están fijadas por etiqueta y digest. Composer y npm usan sus archivos lock para compartir las mismas dependencias.
Los paquetes del sistema instalados mediante apt durante la construcción no están fijados a un repositorio histórico; la imagen construida no pretende ser reproducible byte por byte.

Consulta el [manual de instalación, configuración y trabajo en clase](docs/MANUAL.md).

## Profesor: completar la plantilla una sola vez

Desde PowerShell, en la raíz del proyecto, con Docker Desktop iniciado y acceso a Internet:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/prepare-template.ps1
```

Este script construye PHP, instala dependencias y genera los lock que falten; prepara la clave local, migra MariaDB, carga un usuario de ejemplo y compila los recursos.
No reemplaza un .env existente ni regenera una clave que ya tenga valor.

Comprobar:

```powershell
docker compose ps
docker compose exec app php artisan --version
docker compose exec app php artisan test
docker compose exec app php artisan migrate:status
```

Abrir http://localhost:8080. Después de verificar:

```powershell
git add .
git diff --cached
git commit -m "Fijar dependencias y validar plantilla"
git tag inicio-curso-v1
```

## Alumnos: primera preparación

Requisitos: Git, Docker con contenedores Linux y un editor. En Windows se recomienda Docker Desktop con WSL2.
No se requiere PHP, MariaDB, Composer o Node en el sistema anfitrión.
Crear un repositorio propio con Use this template en GitHub y clonar ese repositorio.
Ejecutar desde PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```

En WSL/Linux: `bash scripts/setup.sh`. En WSL se recomienda clonar dentro de ~/proyectos.
El script de alumnos exige ambos lock y usa composer install y npm ci.

## Trabajo diario

```powershell
docker compose up -d
docker compose exec app php artisan make:model Producto -m
docker compose exec app php artisan migrate
docker compose exec app php artisan test
docker compose run --rm node npm run build
docker compose logs --tail=100 app
docker compose stop
```

Editar archivos con el editor habitual. Tras cambios en CSS/JS, recompilar recursos con npm run build.
El entorno inicial usa compilación de recursos, sin servidor Vite separado.
Para nuevas dependencias, usar Composer/npm dentro de Docker y confirmar los cambios de ambos manifiestos y sus lock.
No ejecutar composer update como paso de instalación.

## Base de datos y aislamiento

Laravel se conecta a db:3306, base pbl, usuario pbl. MariaDB no publica un puerto en Windows, así que no ocupa el 3306 local.
Los datos persisten en un volumen de Compose; cada clon debe estar en una carpeta de nombre distinto si se ejecutan varios proyectos simultáneos.
El puerto web está limitado a 127.0.0.1:8080. Si está ocupado, cambiar APP_PORT y APP_URL en .env y ejecutar docker compose up -d.
No se requieren cambios en XAMPP, Laragon o MariaDB locales.

Para abrir la consola SQL interna:

```powershell
docker compose exec db mariadb -u pbl -p pbl
```

Escribir la contraseña de desarrollo de .env cuando la solicite.
Las credenciales de .env.example son exclusivamente para desarrollo local.
Cambiar credenciales en .env después de inicializar el volumen no modifica automáticamente usuarios existentes de MariaDB.

`docker compose down` conserva los volúmenes. `docker compose down -v` ELIMINA los datos del proyecto y no debe usarse como cierre diario.

El seeder crea test@example.com con contraseña password si no existe. No incluye pantallas de inicio de sesión.
Cada copia genera su propia APP_KEY; no es necesario compartir claves privadas para tener el mismo entorno.

## Publicar en GitHub como plantilla

Para publicar una nueva plantilla desde la terminal del profesor (solo si aún no existe su repositorio remoto):

```powershell
gh auth login --hostname github.com --web
gh repo create ProyectoBaseLaravel --private --source=. --remote=origin --push
gh repo edit --template
git push origin inicio-curso-v1
```

Ejecutar solo después de generar los lock y completar las comprobaciones.
No subir .env, vendor, node_modules ni archivos de autenticación.
El [manual docente y del alumno](docs/MANUAL.md) incluye WSL2, Docker, Git, configuración de Laravel, trabajo diario y solución de problemas.
