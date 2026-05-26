# ============================================================================
# Stage 1: Build assets (Node.js) — se descarta después, reduce imagen final
# ============================================================================
FROM node:20-alpine AS assets-builder

WORKDIR /build

# Copiar solo lo necesario para instalar dependencias (cache de capas)
COPY package.json package-lock.json ./
RUN npm ci --prefer-offline --no-audit

# Copiar archivos de configuración y recursos para compilar
COPY vite.config.js postcss.config.js tailwind.config.js ./
COPY resources ./resources

RUN npm run build

# ============================================================================
# Stage 2: Instalar dependencias PHP (Composer)
# ============================================================================
FROM composer:2 AS composer-builder

WORKDIR /build

COPY composer.json composer.lock ./
RUN composer install \
    --no-dev \
    --no-scripts \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

COPY . .
RUN composer dump-autoload --optimize --no-dev

# ============================================================================
# Stage 3: Imagen final de producción
# ============================================================================
FROM php:8.2-cli-alpine

# ── Dependencias del sistema (Alpine = imagen más liviana) ───────────────────
RUN apk add --no-cache \
    libpng-dev \
    oniguruma-dev \
    libxml2-dev \
    libzip-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    icu-dev \
    zip \
    unzip \
    curl

# ── Extensiones PHP ─────────────────────────────────────────────────────────
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl \
        dom \
        xml \
        fileinfo \
        ctype \
        tokenizer

# ── Optimización PHP para producción ─────────────────────────────────────────
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN echo "opcache.enable=1" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.memory_consumption=128" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.interned_strings_buffer=8" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.max_accelerated_files=10000" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.validate_timestamps=0" >> "$PHP_INI_DIR/conf.d/opcache.ini" \
    && echo "opcache.save_comments=1" >> "$PHP_INI_DIR/conf.d/opcache.ini"

# Habilitar OPcache
RUN docker-php-ext-enable opcache

WORKDIR /var/www/html

# ── Copiar código de la aplicación ───────────────────────────────────────────
COPY . .

# ── Copiar dependencias PHP desde el stage de Composer ───────────────────────
COPY --from=composer-builder /build/vendor ./vendor

# ── Copiar assets compilados desde el stage de Node ──────────────────────────
COPY --from=assets-builder /build/public/build ./public/build

# ── Permisos de Laravel ──────────────────────────────────────────────────────
RUN mkdir -p storage/logs \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# ── Puerto (Railway inyecta $PORT automáticamente) ───────────────────────────
EXPOSE 8000

# ── Script de inicio optimizado ──────────────────────────────────────────────
CMD sh -c "\
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache && \
    php artisan migrate --force && \
    php artisan serve --host=0.0.0.0 --port=\${PORT:-8000}"
