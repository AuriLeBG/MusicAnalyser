# ===========================================
# Base Stage - Install Flutter
# ===========================================
FROM ubuntu:latest AS base

# 1. Prérequis
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# 2. User setup
RUN groupadd -r developer && useradd -r -g developer -m developer
WORKDIR /home/developer
RUN chown -R developer:developer /home/developer
USER developer

# 3. Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable
ENV PATH="$PATH:/home/developer/flutter/bin"
RUN flutter config --enable-web
RUN flutter doctor

# ===========================================
# Development Stage (Auto-reload via inotify)
# ===========================================
FROM base AS development
USER root
WORKDIR /app

# On autorise Git (indispensable)
RUN git config --global --add safe.directory /app
RUN git config --global --add safe.directory /home/developer/flutter

# Installer inotify-tools pour surveiller les changements de fichiers
RUN apt-get update && apt-get install -y inotify-tools && rm -rf /var/lib/apt/lists/*

# Script de démarrage avec watcher
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

CMD ["/docker-entrypoint.sh"]

# ===========================================
# Builder Stage (For Production)
# ===========================================
FROM base AS builder
USER root
WORKDIR /app
COPY . .
RUN chown -R developer:developer /app
USER developer
RUN flutter build web --release

# ===========================================
# Production Stage (Nginx)
# ===========================================
FROM nginx:alpine AS production
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]