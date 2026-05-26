<p align="center">
  <img src="https://img.shields.io/badge/Laravel-12-FF2D20?style=for-the-badge&logo=laravel&logoColor=white" alt="Laravel 12">
  <img src="https://img.shields.io/badge/PHP-8.2+-777BB4?style=for-the-badge&logo=php&logoColor=white" alt="PHP 8.2+">
  <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL">
  <img src="https://img.shields.io/badge/Tailwind_CSS-3.x-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white" alt="Tailwind CSS">
  <img src="https://img.shields.io/badge/Vite-7.x-646CFF?style=for-the-badge&logo=vite&logoColor=white" alt="Vite">
  <img src="https://img.shields.io/badge/Railway-Deploy-0B0D0E?style=for-the-badge&logo=railway&logoColor=white" alt="Railway">
</p>

# 🐾 LaraPets — Sistema de Adopción de Mascotas

**LaraPets** es una aplicación web completa para la gestión y adopción de mascotas, desarrollada con **Laravel 12**. Permite a los usuarios registrar mascotas, gestionar procesos de adopción y generar reportes en PDF y Excel.

---

## ✨ Características

| Módulo | Descripción |
|--------|-------------|
| 🔐 **Autenticación** | Registro, login y gestión de sesiones con Laravel Breeze |
| 🐕 **Gestión de Mascotas** | CRUD completo para registrar mascotas disponibles para adopción |
| 📋 **Adopciones** | Proceso de solicitud y aprobación de adopciones |
| 📄 **Reportes PDF** | Generación de reportes con DomPDF |
| 📊 **Exportación Excel** | Exportación de datos con Maatwebsite/Excel |
| 🎨 **UI Moderna** | Interfaz responsive con Tailwind CSS y Alpine.js |

---

## 🏗️ Stack Tecnológico

```
Backend:    Laravel 12 · PHP 8.2+
Frontend:   Blade · Tailwind CSS 3 · Alpine.js
Build:      Vite 7 · PostCSS
Base Datos: MySQL 8.0+
Auth:       Laravel Breeze
PDF:        barryvdh/laravel-dompdf
Excel:      maatwebsite/excel
Deploy:     Docker · Railway
```

---

## 🚀 Instalación Local

### Prerrequisitos

- PHP >= 8.2 con extensiones: `pdo_mysql`, `mbstring`, `gd`, `zip`, `intl`, `xml`
- Composer 2.x
- Node.js >= 20.x y npm
- MySQL 8.0+

### Pasos

```bash
# 1. Clonar el repositorio
git clone https://github.com/TU_USUARIO/larapets.git
cd larapets

# 2. Instalar dependencias PHP
composer install

# 3. Configurar entorno
cp .env.example .env
php artisan key:generate

# 4. Configurar base de datos en .env
#    DB_CONNECTION=mysql
#    DB_HOST=127.0.0.1
#    DB_PORT=3306
#    DB_DATABASE=larapets
#    DB_USERNAME=root
#    DB_PASSWORD=tu_password

# 5. Ejecutar migraciones
php artisan migrate

# 6. Instalar dependencias Node y compilar assets
npm install
npm run build

# 7. Iniciar servidor de desarrollo
php artisan serve
```

La aplicación estará disponible en `http://localhost:8000`

### Modo desarrollo (con hot-reload)

```bash
composer dev
```

Esto inicia simultáneamente: servidor PHP, queue worker, logs y Vite dev server.

---

## 🐳 Docker

```bash
# Construir imagen
docker build -t larapets .

# Ejecutar contenedor
docker run -p 8000:8000 \
  -e APP_KEY=base64:tu_key_aqui \
  -e DB_CONNECTION=mysql \
  -e DB_HOST=host.docker.internal \
  -e DB_DATABASE=larapets \
  -e DB_USERNAME=root \
  -e DB_PASSWORD=secret \
  larapets
```

---

## ☁️ Despliegue en Railway

> Consulta la [Guía Completa de Despliegue en Railway](./RAILWAY_DEPLOY_GUIDE.md) para instrucciones detalladas paso a paso.

### Resumen rápido:

1. Conecta tu repositorio de GitHub a Railway
2. Agrega un servicio MySQL desde Railway
3. Configura las variables de entorno
4. ¡Deploy automático! 🎉

---

## 📁 Estructura del Proyecto

```
larapets/
├── app/
│   ├── Exports/          # Exportaciones Excel
│   ├── Http/             # Controllers, Middleware, Requests
│   ├── Imports/          # Importaciones Excel
│   ├── Models/           # Eloquent Models (User, Pet, Adoption)
│   ├── Providers/        # Service Providers
│   └── View/             # View Components
├── config/               # Configuración de Laravel
├── database/
│   ├── factories/        # Model Factories
│   ├── migrations/       # Migraciones de BD
│   └── seeders/          # Seeders
├── public/               # Assets públicos
├── resources/
│   ├── css/              # Estilos (Tailwind)
│   ├── js/               # JavaScript (Alpine.js)
│   └── views/            # Blade Templates
├── routes/
│   ├── web.php           # Rutas web
│   └── auth.php          # Rutas de autenticación
├── storage/              # Cache, logs, sesiones
├── Dockerfile            # Multi-stage build optimizado
├── railway.toml          # Configuración Railway
└── composer.json         # Dependencias PHP
```

---

## 📝 Variables de Entorno

| Variable | Descripción | Ejemplo Producción |
|----------|-------------|-------------------|
| `APP_NAME` | Nombre de la app | `LaraPets` |
| `APP_ENV` | Entorno | `production` |
| `APP_KEY` | Clave de encriptación | `base64:...` |
| `APP_DEBUG` | Modo debug | `false` |
| `APP_URL` | URL de la app | `https://tu-app.up.railway.app` |
| `DB_CONNECTION` | Driver BD | `mysql` |
| `DB_HOST` | Host MySQL | `(proporcionado por Railway)` |
| `DB_PORT` | Puerto MySQL | `3306` |
| `DB_DATABASE` | Nombre BD | `railway` |
| `DB_USERNAME` | Usuario BD | `root` |
| `DB_PASSWORD` | Contraseña BD | `(proporcionado por Railway)` |
| `SESSION_DRIVER` | Driver sesiones | `file` |
| `CACHE_STORE` | Driver cache | `file` |
| `LOG_CHANNEL` | Canal de logs | `stderr` |

---

## 🧪 Testing

```bash
php artisan test
```

---

## 📄 Licencia

Este proyecto está bajo la licencia [MIT](https://opensource.org/licenses/MIT).

---

<p align="center">
  Desarrollado con ❤️ usando <strong>Laravel 12</strong> · ADSO 2929061 B · SENA
</p>
