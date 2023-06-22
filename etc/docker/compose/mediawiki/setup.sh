#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
ENV_PATH=$ROOT_DIR/.env
INIT_PHP_PATH=$ROOT_DIR/init.php
LOCAL_SETTINGS_PATH=$ROOT_DIR/LocalSettings.php

if [[ -f $ENV_PATH ]]; then
    echo "Exists '$ENV_PATH' file" 1>&2
    exit 1
fi

if [[ -f $LOCAL_SETTINGS_PATH ]]; then
    echo "Exists '$LOCAL_SETTINGS_PATH' file" 1>&2
    exit 1
fi

function random_hex
{
    tr -dc "a-f0-9" < /dev/urandom | head -c "${1:-64}"
}

read -r -p "Enter the host (e.g. wiki.example.com): " MEDIAWIKI_HOST
read -r -p "Enter the ACME email: " ACME_EMAIL

read -r -p "Do you want to manually enter your database password? (y/n) " YN
if [[ "$YN" == y ]]; then
    read -r -p "Enter the database password: " MYSQL_PASSWORD
else
    MYSQL_PASSWORD=$(random_hex 64)
fi

DEFAULT_LANGUAGE_CODE=ko
DEFAULT_LOCAL_TIMEZONE=Asia/Seoul

read -r -e -i "$DEFAULT_LANGUAGE_CODE" -p "Enter the language code: " LANGUAGE_CODE
read -r -e -i "$DEFAULT_LOCAL_TIMEZONE" -p "Enter the local timezone: " LOCAL_TIMEZONE

MEDIAWIKI_SECRET_KEY=$(random_hex 64)
MEDIAWIKI_UPGRADE_KEY=$(random_hex 16)
MEDIAWIKI_NAME="Open Source Open Mind"
MEDIAWIKI_NAMESPACE="Osom"

ENV="
MEDIAWIKI_HOST=$MEDIAWIKI_HOST
ACME_EMAIL=$ACME_EMAIL
MYSQL_PASSWORD=$MYSQL_PASSWORD
"

LOCAL_SETTINGS="
\$wgServer = \"https://$MEDIAWIKI_HOST\";
\$wgDBpassword = \"$MYSQL_PASSWORD\";
\$wgSecretKey = \"$MEDIAWIKI_SECRET_KEY\";
\$wgUpgradeKey = \"$MEDIAWIKI_UPGRADE_KEY\";
\$wgLanguageCode = \"$LANGUAGE_CODE\";
\$wgLocaltimezone = \"$LOCAL_TIMEZONE\";
"

REPORT="
Go to page https://$MEDIAWIKI_HOST/mw-config/index.php and continue setting:

Language:
 - Your language: $LANGUAGE_CODE
 - Wiki language: $LANGUAGE_CODE

Existing wiki:
 - Upgrade key: $MEDIAWIKI_UPGRADE_KEY

Connect to database:
 - Database type: MariaDB, MySQL, or compatible
 - Database host: mariadb
 - Database name: my_wiki
 - Database table prefix: wiki
 - Database username: wikiuser
 - Database password: $MYSQL_PASSWORD

Name
 - Name of wiki: $MEDIAWIKI_NAME
 - Project namespace: 'Other (specify)' - $MEDIAWIKI_NAMESPACE

Options:
 - User rights profile: 'Private wiki'
 - Copyright and license: 'No license footer'
 Email settings:
  - Enable outbound email: Disable
 Skins:
  - MinervaNeue
  - MonoBook
  - Timeless
  - Vector - 'Use this skin as default'
 Extensions:
  - Renameuser
  - CodeEditor (requires WikiEditor)
  - WikiEditor
  - Cite
  - Math
  - SyntaxHighlight_GeSHi
  - PdfHandler
  - ConfirmEdit
  - MultimediaViewer
 Images and file uploads:
  - Enable file uploads
 Personalization:
  - Logo (icon): \$wgResourceBasePath/resources/assets/logo.png
  - Sidebar logo (optional): \$wgResourceBasePath/resources/assets/logo.png
 Advanced configuration:
  - Select 'PHP object caching (APC, APCu or WinCache)'
"

echo "$ENV" | sed '/^$/d' > "$ENV_PATH"
cp -f "$INIT_PHP_PATH" "$LOCAL_SETTINGS_PATH"
echo "$LOCAL_SETTINGS" >> "$LOCAL_SETTINGS_PATH"
echo "$REPORT"
