# ☁️ Guía Completa de Despliegue en Railway — LaraPets

> Guía paso a paso para desplegar LaraPets en Railway con builds optimizados y cero errores.

---

## 📋 Tabla de Contenidos

1. [Prerrequisitos](#-prerrequisitos)
2. [Paso 1: Preparar el Repositorio](#-paso-1-preparar-el-repositorio)
3. [Paso 2: Crear el Proyecto en Railway](#-paso-2-crear-el-proyecto-en-railway)
4. [Paso 3: Agregar Base de Datos MySQL](#-paso-3-agregar-base-de-datos-mysql)
5. [Paso 4: Configurar Variables de Entorno](#-paso-4-configurar-variables-de-entorno)
6. [Paso 5: Desplegar la Aplicación](#-paso-5-desplegar-la-aplicación)
7. [Paso 6: Verificar el Despliegue](#-paso-6-verificar-el-despliegue)
8. [Optimizaciones de Build](#-optimizaciones-de-build)
9. [Solución de Errores Comunes](#-solución-de-errores-comunes)
10. [Monitoreo y Mantenimiento](#-monitoreo-y-mantenimiento)

---

## 📌 Prerrequisitos

| Requisito | Detalle |
|-----------|---------|
| **Cuenta en Railway** | Regístrate en [railway.app](https://railway.app) (tiene plan gratuito con $5 USD de crédito/mes) |
| **Cuenta en GitHub** | El repositorio debe estar subido a GitHub |
| **Git instalado** | Para gestionar el código localmente |

---

## 🔧 Paso 1: Preparar el Repositorio

### 1.1 Verificar archivos clave

Asegúrate de que tu repositorio contiene estos archivos (ya incluidos en el proyecto):

```
✅ Dockerfile          → Build multi-stage optimizado
✅ railway.toml        → Configuración específica de Railway
✅ .dockerignore       → Excluye archivos innecesarios del build
✅ .env.example        → Template de variables de entorno
✅ composer.json       → Dependencias PHP
✅ package.json        → Dependencias Node.js
```

### 1.2 Verificar el `.env.example`

Asegúrate de que el archivo `.env.example` tiene las configuraciones correctas para producción. **No subas el archivo `.env` al repositorio** — Railway maneja las variables de entorno de forma segura.

### 1.3 Push a GitHub

```bash
git add .
git commit -m "Preparar para despliegue en Railway"
git push origin main
```

---

## 🚂 Paso 2: Crear el Proyecto en Railway

### 2.1 Iniciar sesión en Railway

1. Ve a [railway.app](https://railway.app)
2. Haz clic en **"Login"** → Inicia sesión con tu cuenta de **GitHub**

### 2.2 Crear nuevo proyecto

1. En el dashboard, haz clic en **"New Project"**
2. Selecciona **"Deploy from GitHub repo"**
3. Si es la primera vez, autoriza Railway para acceder a tus repositorios
4. Busca y selecciona el repositorio **`larapets`**
5. Haz clic en **"Deploy Now"**

> ⚠️ **IMPORTANTE**: NO hagas deploy todavía si no has configurado la base de datos. Si Railway inicia el build automáticamente, **cancela el deploy** desde el panel. Primero necesitas configurar MySQL.

---

## 🗄️ Paso 3: Agregar Base de Datos MySQL

### 3.1 Agregar servicio MySQL

1. Dentro de tu proyecto en Railway, haz clic en **"+ New"** (botón superior derecho)
2. Selecciona **"Database"** → **"MySQL"**
3. Railway creará automáticamente una instancia MySQL con credenciales generadas

### 3.2 Obtener credenciales de MySQL

1. Haz clic en el servicio **MySQL** que acabas de crear
2. Ve a la pestaña **"Variables"**
3. Encontrarás las siguientes variables (Railway las genera automáticamente):

```
MYSQL_HOST          → Host del servidor MySQL
MYSQL_PORT          → Puerto (generalmente 3306)
MYSQL_DATABASE      → Nombre de la base de datos (generalmente "railway")
MYSQL_USER          → Usuario (generalmente "root")
MYSQL_PASSWORD      → Contraseña generada
MYSQL_URL           → URL de conexión completa
```

> 📝 **NOTA**: Copia estos valores, los necesitarás en el siguiente paso.

---

## ⚙️ Paso 4: Configurar Variables de Entorno

### 4.1 Ir a las variables del servicio web

1. Haz clic en tu servicio **web** (el que contiene tu código Laravel)
2. Ve a la pestaña **"Variables"**
3. Haz clic en **"New Variable"** o **"RAW Editor"** para agregar múltiples variables

### 4.2 Variables de entorno requeridas

Agrega las siguientes variables **una por una** o usa el **RAW Editor** para copiar todo de una vez:

```env
# ── Aplicación ────────────────────────────────────────────────
APP_NAME=LaraPets
APP_ENV=production
APP_DEBUG=false
APP_URL=https://TU-SERVICIO.up.railway.app
APP_KEY=

# ── Base de Datos ─────────────────────────────────────────────
DB_CONNECTION=mysql
DB_HOST=${{MySQL.MYSQLHOST}}
DB_PORT=${{MySQL.MYSQLPORT}}
DB_DATABASE=${{MySQL.MYSQLDATABASE}}
DB_USERNAME=${{MySQL.MYSQLUSER}}
DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}

# ── Sesiones y Cache (file para Railway) ──────────────────────
SESSION_DRIVER=file
SESSION_LIFETIME=120
CACHE_STORE=file
QUEUE_CONNECTION=sync

# ── Logs (stderr para que Railway los capture) ────────────────
LOG_CHANNEL=stderr
LOG_LEVEL=error

# ── Otros ─────────────────────────────────────────────────────
FILESYSTEM_DISK=local
BCRYPT_ROUNDS=12
```

### 4.3 Referencias de Variables Railway (`${{}}`)

> 💡 **TIP IMPORTANTE**: Usa la sintaxis `${{MySQL.VARIABLE}}` para referenciar las variables del servicio MySQL. Esto permite que Railway inyecte las credenciales automáticamente sin hardcodearlas.

Para configurar las referencias:
1. En el editor de variables, escribe el nombre de la variable (ej: `DB_HOST`)
2. En el valor, escribe `${{MySQL.MYSQLHOST}}`
3. Railway resolverá automáticamente la referencia

### 4.4 Generar APP_KEY

Railway no tiene un generador automático de APP_KEY. Tienes dos opciones:

**Opción A — Generar localmente:**
```bash
php artisan key:generate --show
```
Copia el resultado (ej: `base64:xxxxx...`) y pégalo como valor de `APP_KEY`.

**Opción B — Generar desde la terminal de Railway:**
1. Instala Railway CLI: `npm install -g @railway/cli`
2. Login: `railway login`
3. Vincula el proyecto: `railway link`
4. Ejecuta: `railway run php artisan key:generate --show`

---

## 🚀 Paso 5: Desplegar la Aplicación

### 5.1 Trigger del deploy

Una vez configuradas todas las variables:

1. Ve a la pestaña **"Deployments"** de tu servicio web
2. Si el deploy inicial falló, haz clic en **"Redeploy"**
3. O simplemente haz un push a GitHub — Railway hace deploy automático

### 5.2 Monitorear el build

1. Haz clic en el deployment activo
2. Ve a la pestaña **"Build Logs"** para ver el progreso

El build multi-stage pasará por estas fases:

```
📦 Stage 1/3: Building assets (Node.js)
   → npm ci
   → npm run build (Vite compila CSS/JS)

📦 Stage 2/3: Installing PHP dependencies (Composer)
   → composer install --no-dev --optimize-autoloader

📦 Stage 3/3: Building production image (PHP Alpine)
   → Instalando extensiones PHP
   → Configurando OPcache
   → Copiando código y dependencias
```

### 5.3 Tiempos estimados de build

| Fase | Primera vez | Builds posteriores (con cache) |
|------|-------------|-------------------------------|
| Assets (Node) | 30-60 seg | 10-20 seg |
| Composer | 60-90 seg | 15-30 seg |
| Imagen final | 120-180 seg | 30-60 seg |
| **Total** | **~5 min** | **~1-2 min** |

---

## ✅ Paso 6: Verificar el Despliegue

### 6.1 Comprobar que la app está online

1. Una vez completado el deploy, Railway generará una URL pública
2. Si no aparece, ve a **Settings** → **Networking** → **Generate Domain**
3. Haz clic en la URL generada (ej: `https://larapets-production.up.railway.app`)

### 6.2 Verificar la base de datos

Si las migraciones se ejecutaron correctamente (se ejecutan automáticamente en el CMD del Dockerfile), deberías poder:

- Registrar un nuevo usuario
- Crear una mascota
- Realizar una adopción

### 6.3 Verificar logs

1. Ve a **"Deployments"** → deployment activo
2. Pestaña **"Deploy Logs"** para ver los logs de la aplicación en tiempo real

---

## ⚡ Optimizaciones de Build

El Dockerfile de este proyecto ya incluye las siguientes optimizaciones:

### Multi-Stage Build
```
🔹 Imagen Node.js    → Solo para compilar assets (se descarta)
🔹 Imagen Composer   → Solo para instalar PHP deps (se descarta)
🔹 Imagen PHP Alpine → Imagen final ~80% más pequeña que Debian
```

### Cache de Capas Docker
```dockerfile
# Las dependencias se copian PRIMERO → Docker cachea esta capa
COPY package.json package-lock.json ./
RUN npm ci

# El código se copia DESPUÉS → Solo se reconstruye si cambia
COPY resources ./resources
RUN npm run build
```

### OPcache habilitado
```
✅ opcache.enable=1
✅ opcache.validate_timestamps=0   (no verifica cambios en producción)
✅ opcache.max_accelerated_files=10000
✅ opcache.memory_consumption=128MB
```

### Cache de Laravel en producción
```bash
php artisan config:cache    # Cachea config en un solo archivo
php artisan route:cache     # Cachea rutas compiladas
php artisan view:cache      # Pre-compila vistas Blade
```

### .dockerignore configurado
```
node_modules, vendor, .git, tests, logs, etc.
→ Reduce el contexto de build en ~80%
→ Builds más rápidos
```

---

## 🔧 Solución de Errores Comunes

### ❌ Error: "No application encryption key has been specified"

**Causa**: No se configuró `APP_KEY` en las variables de entorno.

**Solución**:
```bash
# Generar localmente
php artisan key:generate --show
# Copiar el resultado y pegarlo en Railway → Variables → APP_KEY
```

---

### ❌ Error: "SQLSTATE[HY000] [2002] Connection refused"

**Causa**: Las credenciales de MySQL no están configuradas correctamente.

**Solución**:
1. Verifica que el servicio MySQL está corriendo en Railway
2. Verifica que las variables `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` están configuradas
3. Si usas referencias (`${{MySQL.MYSQLHOST}}`), verifica que el nombre del servicio MySQL coincide

---

### ❌ Error: "npm ERR! could not determine executable to run"

**Causa**: Conflicto entre versiones de Node.js.

**Solución**: El Dockerfile ya usa `node:20-alpine` explícitamente, no debería ocurrir. Si ocurre:
1. Verifica que `package-lock.json` está en el repositorio
2. Ejecuta localmente `rm -rf node_modules && npm ci` y haz commit de `package-lock.json`

---

### ❌ Error: "Class 'Maatwebsite\Excel\...' not found"

**Causa**: La extensión `ext-gd` no está instalada.

**Solución**: El Dockerfile ya incluye la extensión `gd`. Si ocurre:
```dockerfile
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd
```

---

### ❌ Error: Build timeout (> 10 minutos)

**Causa**: Railway tiene un timeout de build de 15 minutos en el plan gratuito.

**Solución**:
1. Verifica que `.dockerignore` está en el repositorio (reduce el contexto)
2. El multi-stage build debería completar en ~5 min la primera vez
3. Builds posteriores deberían ser ~1-2 min gracias al cache

---

### ❌ Error: "Vite manifest not found at: /var/www/html/public/build/manifest.json"

**Causa**: Los assets no se compilaron correctamente.

**Solución**:
1. Verifica que `vite.config.js` está en el repositorio
2. Verifica que `resources/css/app.css` y `resources/js/app.js` existen
3. En los Build Logs, busca la fase "Stage 1: Building assets" y verifica que `npm run build` fue exitoso

---

### ❌ Error: "Permission denied" en storage/

**Causa**: Permisos incorrectos en las carpetas de almacenamiento.

**Solución**: El Dockerfile ya configura los permisos:
```dockerfile
RUN chmod -R 775 storage bootstrap/cache
```

---

### ❌ La app carga pero no se ven estilos CSS

**Causa**: `APP_URL` no coincide con la URL real de Railway.

**Solución**:
1. Copia la URL pública de Railway (ej: `https://larapets-production.up.railway.app`)
2. Actualiza `APP_URL` en las variables de Railway con esa URL exacta
3. Redeploy

---

## 📊 Monitoreo y Mantenimiento

### Ver logs en tiempo real
1. Dashboard de Railway → tu servicio → **Deployments** → deployment activo
2. Pestaña **"Deploy Logs"**

### Ejecutar comandos Artisan en Railway
```bash
# Instalar Railway CLI
npm install -g @railway/cli

# Login y vincular proyecto
railway login
railway link

# Ejecutar comandos
railway run php artisan migrate:status
railway run php artisan cache:clear
railway run php artisan config:clear
```

### Dominio personalizado
1. Ve a **Settings** → **Networking** → **Custom Domain**
2. Agrega tu dominio (ej: `larapets.tudominio.com`)
3. Configura el CNAME en tu proveedor DNS apuntando a Railway
4. Actualiza `APP_URL` con tu nuevo dominio

### Redeploy manual
- Haz push a `main` → Deploy automático
- O en Railway: **Deployments** → **"Redeploy"**

---

## 💰 Plan de costos Railway

| Plan | Crédito/mes | RAM | CPU | Disco |
|------|-------------|-----|-----|-------|
| **Trial** | $5 USD gratis | 512 MB | Compartido | 1 GB |
| **Hobby** | $5 USD + uso | 8 GB | 8 vCPU | 100 GB |
| **Pro** | $20 USD + uso | 32 GB | 32 vCPU | 500 GB |

> 💡 Para un proyecto como LaraPets, el plan **Trial** o **Hobby** es más que suficiente.

---

## 📝 Resumen de Archivos de Configuración

| Archivo | Propósito |
|---------|-----------|
| `Dockerfile` | Build multi-stage optimizado (Node → Composer → PHP Alpine) |
| `railway.toml` | Configuración específica de Railway (health check, restart policy) |
| `.dockerignore` | Excluye archivos innecesarios del build (~80% menos contexto) |
| `.env.example` | Template de variables de entorno |

---

<p align="center">
  <strong>🎉 ¡Listo! Tu aplicación LaraPets debería estar corriendo en Railway.</strong>
  <br><br>
  Si tienes problemas, revisa la sección de <a href="#-solución-de-errores-comunes">Solución de Errores Comunes</a>.
</p>
