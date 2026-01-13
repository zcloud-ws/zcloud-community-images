FROM jaegertracing/all-in-one:1.75.0

USER root

RUN apk add --no-cache \
    nginx~=1.28 \
    apache2-utils~=2.4 && \
    mkdir -p /run/nginx /var/lib/nginx/tmp && \
    chmod -R 777 /var/lib/nginx /var/log/nginx

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 16687 4318 16686

ENTRYPOINT ["/entrypoint.sh"]