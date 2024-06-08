FROM nginx/nginx-prometheus-exporter as exporter
FROM nginx:alpine

ENV PORT 80

WORKDIR /app

COPY app/ /usr/share/nginx/html
# copy config and exporter
COPY --from=exporter /usr/bin/nginx-prometheus-exporter /usr/bin/nginx-prometheus-exporter
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/supervisor.conf /etc/supervisor/supervisor.conf

RUN apk add --no-cache supervisor


EXPOSE 80 9113
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisor.conf"]
