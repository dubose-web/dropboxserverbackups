<?php

require __DIR__ . '/vendor/autoload.php';

$args = [];

foreach ($argv as $arg) {
    $hasDashes = mb_strpos($arg, '--') === 0;

    if (!$hasDashes) {
        continue;
    }

    $argParts = explode('=', $arg);

    $key = explode('-', $argParts[0])[2] ?? null;
    $val = $argParts[1] ?? null;

    if ($key === null || $val === null || $key === '' || $val === '') {
        continue;
    }

    $args[$key] = $val;
}

$dropboxToken = $args['dropboxToken'] ?? null;

if ($dropboxToken === null) {
    throw new \Exception('--dropboxToken is required');
}

$dropboxBackDirName = $args['dropboxBackDirName'] ?? null;

if ($dropboxBackDirName === null) {
    throw new \Exception('--dropboxBackDirName is required');
}

$date = $args['date'] ?? null;

if ($date === null) {
    throw new \Exception('--date is required');
}

$client = new Spatie\Dropbox\Client($dropboxToken);

$dir = new DirectoryIterator(__DIR__ . '/backups/' . $date);

try {
    foreach ($dir as $fileInfo) {
        if ($fileInfo->isDot()) {
            continue;
        }

        $file = fopen($fileInfo->getPathname(), 'r');

        $client->upload(
            '/' . $dropboxBackDirName . '/' . $date . '/' . $fileInfo->getFilename(),
            $file
        );

        sleep(1);
    }
} catch (\Spatie\Dropbox\Exceptions\BadRequest $e) {
    echo (string) $e->response->getBody();
    throw $e;
}
