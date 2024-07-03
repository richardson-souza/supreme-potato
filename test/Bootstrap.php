<?php

declare(strict_types=1);

date_default_timezone_set('Etc/GMT+3');

ini_set('xdebug.mode', 'coverage');

define('RESOURCE_USAGE', (array)(getrusage() ?? []));
define('START_EXECUTION_TIME', microtime(true));
define('APP_ROOT', dirname(realpath(__DIR__)));

// This makes our life easier when dealing with paths. Everything is relative to the application root now.
chdir(dirname(realpath(__DIR__)));

// Setup auto-loading
require 'vendor/autoload.php';
