#!/usr/bin/env bash

set -e;

source env.sh

echo "Visit https://www.dropbox.com/oauth2/authorize?response_type=code&token_access_type=offline&client_id=l6sv1c0jtuemwln";
echo "Click \"Continue\"";
echo "Then click \"Allow\""''
echo "Paste the resulting code string below";
read -p "Code: " CODE;

echo "Use the following refresh code in your env.sh file";
echo $(curl -s https://api.dropbox.com/oauth2/token -d code="${CODE}" -d grant_type=authorization_code -u "${DROPBOX_APP_KEY}":"${DROPBOX_APP_SECRET}");
