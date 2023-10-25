FROM --platform=linux/amd64 nginx:alpine
ENV PORT 80

COPY app/ /usr/share/nginx/html

EXPOSE 80