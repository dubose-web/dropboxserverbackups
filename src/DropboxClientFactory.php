<?php


declare(strict_types=1);

namespace App;

use MNIB\SpatieDropboxApiRefreshableToken\AutoRefreshableTokenProvider;
use Spatie\Dropbox\Client;

readonly class DropboxClientFactory
{
    public function __construct(
        private CliInput $cliInput,
    ) {
    }

    public function create(): Client
    {
        $tokenProvider = new AutoRefreshableTokenProvider(
            $this->cliInput->getArg('dropboxAppKey'),
            $this->cliInput->getArg('dropboxAppSecret'),
            $this->cliInput->getArg('dropboxRefreshToken'),
        );

        return new Client($tokenProvider);
    }
}
