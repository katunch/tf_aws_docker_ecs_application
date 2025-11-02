FROM nginx:alpine
ADD ./etc/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./etc/nginx/templates /etc/nginx/templates
COPY ./etc/nginx/docker-entrypoint.d/100-extended-config.sh /docker-entrypoint.d/100-extended-config.sh
RUN rm /etc/nginx/conf.d/default.conf && \
    chmod +x /docker-entrypoint.d/100-extended-config.sh
