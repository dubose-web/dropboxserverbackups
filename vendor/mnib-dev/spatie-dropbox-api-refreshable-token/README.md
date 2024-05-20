# Usage

### How to get refresh token
- Visit https://www.dropbox.com/oauth2/authorize?response_type=code&token_access_type=offline&client_id=<APP_KEY>
- Copy that access code to use in the step below
- In the terminal use the access code provided above
  
  `curl https://api.dropbox.com/oauth2/token -d code=<ACCESS_CODE> -d grant_type=authorization_code -u <APP_KEY>:<APP_SECRET>`
- Save refresh token

```php
<?php

declare(strict_types=1);

$appKey = '';
$appSecret = ''; 
$refreshToken = '';

$tokenProvider = new AutoRefreshableTokenProvider($appKey, $appSecret, $refreshToken);
$dropboxClient = new Spatie\Dropbox\Client($tokenProvider);
```
