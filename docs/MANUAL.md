# Manual del proyecto base Laravel

## 1. Qué instala cada persona

En la computadora: Git, Docker Desktop y un editor. En Windows se usa el motor Linux de Docker con WSL 2. PHP, Composer, MariaDB y Node se ejecutan en contenedores del proyecto; no hace falta instalar esas herramientas en Windows ni modificar XAMPP o Laragon.

El código vive en la carpeta clonada. MariaDB guarda sus datos en un volumen Docker. Cada alumno crea su propio repositorio a partir de la plantilla y genera su propia clave de Laravel.

## 2. Preparar Windows y WSL

Si ya funciona Docker con contenedores Linux, pasar a la sección 4. Antes de instalar, revisar los [requisitos actuales de Docker Desktop](https://docs.docker.com/desktop/setup/install/windows-install/), incluida la virtualización del equipo y la compatibilidad de Windows.

En PowerShell como administrador:

```powershell
wsl --install
```

Reiniciar cuando Windows lo solicite y completar la creación de usuario y contraseña de Ubuntu. Luego comprobar:

```powershell
wsl --update
wsl --version
wsl --list --verbose
```

La distribución utilizada debe indicar versión 2. Si una distribución existente usa versión 1, consultar primero la [guía de Microsoft](https://learn.microsoft.com/windows/wsl/install/) antes de convertirla. No eliminar distribuciones existentes: pueden contener trabajo de otras materias.

## 3. Preparar Docker Desktop

Descargar e instalar desde la [página oficial](https://docs.docker.com/desktop/setup/install/windows-install/). Iniciar Docker Desktop y usar contenedores Linux. Para trabajar desde Ubuntu, habilitar su integración en Settings → Resources → WSL Integration, según la [guía del backend WSL](https://docs.docker.com/desktop/features/wsl/).

En una terminal nueva:

```powershell
docker version
docker compose version
docker run --rm hello-world
```

`docker version` debe mostrar Client y Server. Si solo muestra Client, revisar que Docker Desktop esté iniciado. La primera descarga necesita Internet. No instalar un segundo motor Docker dentro de Ubuntu para seguir este manual.

## 4. Preparar Git y el editor

Instalar Git desde [git-scm.com](https://git-scm.com/downloads) y abrir una terminal nueva. Configurar la identidad propia para los commits:

```powershell
git --version
git config --global user.name "Tu nombre"
git config --global user.email "Tu correo de GitHub"
```

Estos dos últimos comandos cambian la identidad predeterminada para todos los repositorios de ese usuario. Si ya está configurada correctamente, conservarla. Para configurarla solo en un proyecto, ejecutarlos dentro del repositorio sin `--global`.

Se puede usar Visual Studio Code u otro editor. Elegir una forma de trabajo y mantenerla:

- **PowerShell:** clonar en una carpeta como `C:\ws\MiProyectoLaravel` y usar `scripts/setup.ps1`.
- **Ubuntu/WSL:** clonar en `~/proyectos/MiProyectoLaravel` y usar `bash scripts/setup.sh`. Git debe estar disponible en Ubuntu. Abrir esa carpeta con el editor integrado con WSL.

No mezclar una copia Windows y otra WSL creyendo que son el mismo proyecto.

## 5. Crear la copia del alumno

En GitHub, abrir la plantilla proporcionada por el profesor, seleccionar **Use this template → Create a new repository**, elegir propietario y nombre, y crear el repositorio. Si la plantilla es privada, primero se necesita acceso del profesor. Véase la [guía oficial de plantillas](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).

Copiar la URL HTTPS del repositorio nuevo. En PowerShell, por ejemplo:

```powershell
cd C:\ws
git clone https://github.com/TU_USUARIO/MiProyectoLaravel.git
cd MiProyectoLaravel
powershell -ExecutionPolicy Bypass -File scripts/setup.ps1
```

Sustituir `TU_USUARIO` y el nombre por los reales. En Ubuntu, después de clonar:

```bash
cd ~/proyectos/MiProyectoLaravel
bash scripts/setup.sh
```

Esperar a que termine sin errores. Abrir [la aplicación local](http://localhost:8080).

## 6. Qué hace la preparación

1. Copia `.env.example` a `.env` únicamente si no existe.
2. Exige `composer.lock` y `package-lock.json` para instalar las dependencias acordadas.
3. Construye PHP e instala dependencias mediante Composer dentro del contenedor.
4. Genera `APP_KEY` si falta una clave con el formato esperado.
5. Inicia MariaDB y espera su comprobación de salud.
6. Aplica migraciones y carga los datos iniciales.
7. Instala dependencias de JavaScript con `npm ci` y compila con Vite.
8. Inicia Laravel en el puerto local 8080.

La descarga y compilación inicial pueden tardar varios minutos. Si una etapa falla, corregir la causa y repetir el script. No borrar volúmenes como medida habitual de reparación.

## 7. Configuración del proyecto

| Archivo o carpeta | Función |
| --- | --- |
| `compose.yaml` | Servicios app, db y node; puertos y volúmenes |
| `docker/php/Dockerfile` | PHP, Composer y extensiones |
| `.env.example` | Valores de desarrollo que cada copia toma como punto de partida |
| `.env` | Configuración y clave propias; excluido de Git |
| `composer.lock` | Versiones resueltas de dependencias PHP |
| `package-lock.json` | Versiones resueltas de dependencias JavaScript |
| `routes/web.php` | Rutas web |
| `resources/views` | Vistas Blade |
| `app/Models` | Modelos Eloquent |
| `database/migrations` | Cambios del esquema |
| `database/seeders` | Datos iniciales |
| `tests` | Pruebas automatizadas |

Laravel conecta a `db:3306`, base `pbl`, usuario `pbl`. El servicio MariaDB no publica puertos en Windows. Las credenciales incluidas son de desarrollo local. Cambiarlas en `.env` después de inicializar MariaDB no cambia automáticamente los usuarios de un volumen existente.

El seeder incluye `test@example.com` con contraseña `password`. Es un registro de práctica, no hay pantallas de autenticación implementadas. Sesiones, caché y cola usan tablas de la base. El correo se escribe en los logs. Para procesar trabajos en cola, iniciar un trabajador en otra terminal con `docker compose exec app php artisan queue:work`.

## 8. Trabajo diario

Desde la carpeta que contiene `compose.yaml`, con Docker Desktop iniciado:

```powershell
docker compose up -d
docker compose ps
docker compose exec app php artisan make:model Producto -m
docker compose exec app php artisan migrate
docker compose exec app php artisan test
docker compose run --rm node npm run build
```

El comando `make:model` es un ejemplo: usarlo solo al crear ese modelo. Editar la migración antes de ejecutarla. Recompilar al cambiar CSS o JavaScript; esta plantilla usa recursos compilados, sin servidor Vite separado.

Guardar cambios de código:

```powershell
git status
git add app database resources routes tests
git diff --cached
git commit -m "Describe el cambio realizado"
git push
```

Revisar y agregar otros archivos modificados cuando corresponda. No subir `.env`, `vendor` o `node_modules`. Antes de incorporar cambios del repositorio, guardar el trabajo propio. Después de cambios en los lock, repetir `scripts/setup.ps1` o `scripts/setup.sh`.

Para terminar la sesión:

```powershell
docker compose stop
```

`docker compose down` elimina contenedores y red, pero conserva los volúmenes. **`docker compose down -v` elimina los datos de MariaDB del proyecto.** No usarlo para cerrar la clase.

## 9. Verificación y problemas frecuentes

```powershell
docker compose ps
docker compose exec app php artisan --version
docker compose exec app php artisan migrate:status
docker compose exec app php artisan test
docker compose logs --tail=100 app db
```

| Síntoma | Acción |
| --- | --- |
| No conecta al motor Docker | Iniciar Docker Desktop y verificar `docker version` en una terminal normal |
| Faltan archivos lock | Obtener la plantilla preparada por el profesor; no resolver versiones diferentes por alumno |
| Puerto 8080 ocupado | Cambiar `APP_PORT=8081` y `APP_URL=http://localhost:8081` en `.env`; ejecutar `docker compose up -d` |
| Error de conexión a base | Revisar estado y logs de db; conservar `DB_HOST=db` dentro del contenedor |
| Falta APP_KEY | Repetir el script de preparación |
| No se ven cambios CSS/JS | Ejecutar `docker compose run --rm node npm run build` |
| Configuración anterior en Laravel | Ejecutar `docker compose exec app php artisan optimize:clear` |
| Descarga interrumpida | Revisar Internet/proxy y repetir la preparación |

Las pruebas usan SQLite en memoria, separada de MariaDB de desarrollo. Comprobar además migraciones y la aplicación por HTTP para validar la integración real.

Para una segunda copia simultánea, usar una carpeta con nombre distinto y un `APP_PORT` distinto. No compartir `.env`: cada instalación necesita su propia clave.

## 10. Mantenimiento por el profesor

`scripts/prepare-template.ps1` sirve para preparar la plantilla original y generar los lock faltantes. Los alumnos usan `setup.ps1` o `setup.sh`. Registrar los manifiestos y sus lock juntos cuando se cambien dependencias; `composer update` no es un paso de instalación de alumnos.

Antes de distribuir una nueva versión: probar preparación, migraciones, tests y compilación; revisar `git diff`; confirmar los cambios y crear una etiqueta nueva. La etiqueta `inicio-curso-v1` identifica el punto inicial. Crear repositorios desde plantilla copia su estado seleccionado, no mantiene una sincronización automática con futuras modificaciones del profesor.

Este entorno sirve para desarrollo local. Para alojar aplicaciones se requiere una configuración de producción específica.
