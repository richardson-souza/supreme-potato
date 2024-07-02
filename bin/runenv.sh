#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

GROUP="docker"
CONTAINER_BASENAME="supreme-potato"
RUNNING_CONTAINER=$(docker ps --filter name=${CONTAINER_BASENAME} -q)

# Create docker group
if ! grep -q $GROUP /etc/group; then
    echo "Criando grupo docker: ${GROUP}."
    groupadd $GROUP
fi

# Add user to docker group and apply immediately
if ! groups "$USER" | grep &>/dev/null "\b${GROUP}\b"; then
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Adicionando usuário ao grupo docker: ${USER}."
    usermod -aG $GROUP "$USER"
    newgrp $GROUP
fi

# Increase vm.max_map_count
if ! [[ $(sysctl vm.max_map_count | awk -F' ' '{print $3}') =~ 262144 ]]; then
    sysctl -w vm.max_map_count=262144
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Configurado vm.max_map_count."
fi

# Increase fs.file-max
if ! [[ $(sysctl fs.file-max | awk -F' ' '{print $3}') =~ 65536 ]]; then
    sysctl -w -q fs.file-max=65536
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Configurado fs.file-max."
fi

ulimit -n 65536
ulimit -u 4096
ulimit -c unlimited
ulimit -s unlimited

if [[ -n $RUNNING_CONTAINER ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 3)WARNING$(tput sgr0) Containers já em execução."
    for c in $RUNNING_CONTAINER; do
        docker stop "$c" && docker rm "$c"
    done
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Aplicado comando docker stop."
fi

# Config development mode (Mezzio framework)
cp ./config/development.config.php.dist ./config/development.config.php
cp ./config/autoload/development.local.php.dist ./config/autoload/development.local.php
cp ./config/autoload/local.php.dist ./config/autoload/local.php
#cp ./config/autoload/routes.local.php.dist ./config/autoload/routes.local.php
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Configurado modo de desenvolvimento."

# Setup bin (folder permission)
chmod -R +x ./bin
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Alterado permissão: ./bin"

# Setup cache (Clear and folder permission)
rm -Rf ./cache
mkdir -m 777 ./cache
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Realizado limpeza do cache."

# # Setup local database(s) (Folder permission)
# chmod -R 777 ./database
# echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Alterado permissão: ./database"

# Setup environment (Folder permission)
chmod -R 777 ./environment
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Alterado permissão: ./environment"

# Setup logs (Clear and folder permission)
rm -Rf ./log
mkdir -m 777 ./log

rm -Rf ./environment/nginx/log
mkdir -m 777 ./environment/nginx/log

rm -Rf ./environment/php/log
mkdir -m 777 ./environment/php/log
mkdir -m 777 ./environment/php/log/php
mkdir -m 777 ./environment/php/log/supervisor
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Realizado limpeza de logs."

# Setup .env
ln -sf environment/development.env .env
# cp environment/testing.env tests/.env
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Gerado arquivo de configurações do ambiente."

# Docker up
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 4)INFO$(tput sgr0) Carregando o ambiente."
docker network create supreme-potato-networks
docker compose up $1

# Docker down
echo ""
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput setaf 2)That's all, folks...$(tput sgr0)"
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput setaf 2)Goodbye!$(tput sgr0)"
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') $(tput bold)$(tput setaf 2);)$(tput sgr0)"
echo ""
