<?php

declare(strict_types=1);

namespace MNIB\SpatieDropboxApiRefreshableToken;

use GuzzleHttp\Client as HttpClient;
use GuzzleHttp\Exception\ClientException;
use Spatie\Dropbox\RefreshableTokenProvider;
use Throwable;

use function json_decode;

class AutoRefreshableTokenProvider implements RefreshableTokenProvider
{
    /** @var string */
    private $appKey;

    /** @var string */
    private $appSecret;

    /** @var string */
    private $refreshToken;

    /** @var string|null */
    private $accessToken;

    public function __construct(string $appKey, string $appSecret, string $refreshToken)
    {
        $this->appKey = $appKey;
        $this->appSecret = $appSecret;
        $this->refreshToken = $refreshToken;
    }

    public function getToken(): string
    {
        return (string)$this->accessToken;
    }

    public function refresh(ClientException $exception): bool
    {
        $httpClient = new HttpClient();

        try {
            $response = $httpClient->post('https://api.dropbox.com/oauth2/token', [
                'auth' => [$this->appKey, $this->appSecret],
                'form_params' => [
                    'grant_type' => 'refresh_token',
                    'refresh_token' => $this->refreshToken,
                ],
            ]);

            if ($response->getStatusCode() === 200) {
                $response = json_decode((string)$response->getBody(), true);
                $this->accessToken = $response['access_token'];

                return true;
            }
        } catch (Throwable $ex) {
            // no-op
        }

        return false;
    }
}
