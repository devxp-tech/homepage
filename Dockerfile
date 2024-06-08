# Use the official Nginx base image
FROM nginx:alpine

# Install curl to fetch nginx-prometheus-exporter
RUN apk add --no-cache curl tar

# Set the version of nginx-prometheus-exporter to install
ENV NGINX_PROMETHEUS_EXPORTER_VERSION=1.1.2

# Download and install nginx-prometheus-exporter
RUN curl -L https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v${NGINX_PROMETHEUS_EXPORTER_VERSION}/nginx-prometheus-exporter_${NGINX_PROMETHEUS_EXPORTER_VERSION}_linux_amd64.tar.gz \
    | tar -zx -C /usr/local/bin

# Copy the static application files to the Nginx document root
COPY ./app /usr/share/nginx/html

# Copy the health check file
COPY health-check/liveness/index.html /usr/share/nginx/html/health-check/liveness/index.html
COPY health-check/readiness/index.html /usr/share/nginx/html/health-check/readiness/index.html


# Copy the custom Nginx configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY conf/stub_status.conf /etc/nginx/conf.d/stub_status.conf

# Expose ports for Nginx and Prometheus metrics
EXPOSE 80 9090

# Add a health check instruction
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD curl -f http://localhost/health-check/liveness || exit 1

# Start Nginx and nginx-prometheus-exporter
CMD ["sh", "-c", "nginx -g 'daemon off;' & nginx-prometheus-exporter -nginx.scrape-uri http://127.0.0.1:8080/stub_status -web.listen-address :9090"]
