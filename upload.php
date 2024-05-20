<?php

use App\CliInput;
use App\DropboxClientFactory;
use Spatie\Dropbox\Exceptions\BadRequest;

require __DIR__ . '/vendor/autoload.php';


/**
 * Gather Requirements
 */

$cliInput = new CliInput($argv);

$dropboxBackupDirName = $cliInput->getArg('dropboxBackupDirName');

$date = $cliInput->getArg('date');

$dropboxClientFactory = new DropboxClientFactory($cliInput);

$dropboxClient = $dropboxClientFactory->create();


/**
 * Run
 */

$dir = new DirectoryIterator(__DIR__ . '/backups/' . $date);

try {
    foreach ($dir as $fileInfo) {
        if ($fileInfo->isDot()) {
            continue;
        }

        $file = fopen($fileInfo->getPathname(), 'r');

        $dropboxClient->upload(
            '/' . $dropboxBackupDirName . '/' . $date . '/' . $fileInfo->getFilename(),
            $file
        );
    }
} catch (BadRequest $e) {
    echo (string) $e->response->getBody();
    throw $e;
}
