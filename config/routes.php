<?php

declare(strict_types=1);

use App\Application\Rest\Handler\V1;
use Mezzio\Application;

$baseUrl = '/api/v1';

return static function (Application $app) use ($baseUrl) {
    $app->get("{$baseUrl}/ping", V1\PingHandler::class, 'api.ping');
};
