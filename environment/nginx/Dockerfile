FROM nginx:alpine

LABEL maintainer="richardson.allan.souza@gmail.com"

ENV ACCEPT_EULA=Y

ARG DEFAULT_PORT=80
ARG SERVER_NAME="dev.supreme-potato.com.br"
ARG PHP_CONTAINER_HOST="supreme-potato-php"
ARG PHP_CONTAINER_PORT=9000
ARG SUPERVISOR_GUI_PORT=9001

RUN apk add --no-cache sed

COPY environment/nginx/rootfilesystem/ /

RUN sed -i "s/{PHP_CONTAINER_HOST}/$PHP_CONTAINER_HOST/" /etc/nginx/conf.d/application.conf \
 && sed -i "s/{PHP_CONTAINER_PORT}/$PHP_CONTAINER_PORT/" /etc/nginx/conf.d/application.conf \
 && sed -i "s/{SERVER_NAME}/$SERVER_NAME/" /etc/nginx/conf.d/application.conf \
 && sed -i "s/{DEFAULT_PORT}/$DEFAULT_PORT/" /etc/nginx/conf.d/application.conf

RUN sed -i "s/{PHP_CONTAINER_HOST}/$PHP_CONTAINER_HOST/" /etc/nginx/conf.d/supervisor.conf \
 && sed -i "s/{SUPERVISOR_GUI_PORT}/$SUPERVISOR_GUI_PORT/" /etc/nginx/conf.d/supervisor.conf \
 && sed -i "s/{SERVER_NAME}/$SERVER_NAME/" /etc/nginx/conf.d/supervisor.conf
