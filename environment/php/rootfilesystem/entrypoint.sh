#!/bin/bash -e

echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Running .php and .sh scripts under folder /usr/local/boot."

BOOT_SCRIPTS=()

# set nullglob variable
shopt -s nullglob

for f in /usr/local/boot/*.sh; do
    BOOT_SCRIPTS+=("$f")
done

# unset nullglob variable
shopt -u nullglob

IFS=" " read -r -a BOOT_SCRIPTS <<< "$(sort <<< "${BOOT_SCRIPTS[*]}")"
unset IFS

for f in "${BOOT_SCRIPTS[@]}"; do
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Running $f"
    # shellcheck source=./.f
    . "$f"
done

# Config development mode (Mezzio framework)
cp /var/www/config/development.config.php.dist /var/www/config/development.config.php
cp /var/www/config/autoload/development.local.php.dist /var/www/config/autoload/development.local.php
cp /var/www/config/autoload/local.php.dist /var/www/config/autoload/local.php
#cp /var/www/config/autoload/routes.local.php.dist /var/www/config/autoload/routes.local.php
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Setup development mode."

# Setup bin (folder permission)
chmod -R +x /var/www/bin
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Enable exec mode: /var/www/bin"

# Setup cache (Clear and folder permission)
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Removing old files from /var/www/cache"
rm -Rf /var/www/cache && mkdir -p /var/www/cache && chmod -Rf 777 /var/www/cache

# Setup local database(s) (Folder permission)
# chmod -R 777 /var/www/database
# echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Enable read/write mode: /var/www/database"

# Setup logs (Clear and folder permission)
rm -Rf /var/www/log && mkdir -m 777 /var/www/log
rm -Rf /var/log/php && mkdir -m 777 /var/log/php
rm -Rf /var/log/supervisor && mkdir -m 777 /var/log/supervisor
echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Clean logs."

cd /var/www
composer install \
    --no-progress \
    --verbose \
    --no-interaction \
    --profile \
    --audit \
    --ignore-platform-reqs

composer dump-autoload --optimize --apcu

# We use option "-c" here to suppress following warning message from console output:
# UserWarning: Supervisord is running as root and it is searching for its configuration file in default locations...
if [[ -n "$(ls /etc/supervisor.d/*.conf 2>/dev/null)" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Starting supervisor"
    /usr/bin/supervisord -c /etc/supervisord.conf -n
    echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: supervisor started"
else
    tail -f /dev/null
fi
