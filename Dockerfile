# Image nginx non-root (bonne pratique sécurité)
FROM nginxinc/nginx-unprivileged:1.27-alpine

LABEL org.opencontainers.image.title="Maison Arabica"
LABEL org.opencontainers.image.description="Site vitrine café de spécialité"

# Config nginx custom (cache, gzip, sécurité)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Site statique
COPY --chown=nginx:nginx index.html /usr/share/nginx/html/index.html

EXPOSE 8085

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q --spider http://localhost:8085/ || exit 1

# l'image tourne déjà en non-root, commande par défaut conservée
