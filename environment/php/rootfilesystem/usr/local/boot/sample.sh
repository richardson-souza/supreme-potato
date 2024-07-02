#!/usr/bin/env bash

# Sample script showing how to write a script that will be executed automatically when a Docker container is started.

set -e

echo "$(date '+%Y-%m-%d %H:%M:%S,%3N') INFO: Running sample.sh scripts under folder /usr/local/boot."

# php /path/to/a/php/script # To execute a PHP script while booting the container.
