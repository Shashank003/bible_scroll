FROM nginx:stable-alpine

ENV PORT=8080
COPY nginx.conf.template /etc/nginx/templates/default.conf.template
COPY index.html styles.css site.js robots.txt sitemap.xml /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/
COPY apps/ /usr/share/nginx/html/apps/

EXPOSE 8080
