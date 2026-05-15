FROM nginx:1.31.0

# We need to remove the default server.
RUN rm /etc/nginx/conf.d/default.conf

COPY ./nginx/ /etc/nginx/

EXPOSE 80
