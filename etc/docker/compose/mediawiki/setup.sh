#!/usr/bin/env bash

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" || exit; pwd)
ENV_PATH=$ROOT_DIR/.env
LOCAL_SETTINGS_PATH=$ROOT_DIR/LocalSettings.php

if [[ -f $ENV_PATH ]]; then
    echo "Exists '$ENV_PATH' file" 1>&2
    exit 1
fi

if [[ -f $LOCAL_SETTINGS_PATH ]]; then
    echo "Exists '$LOCAL_SETTINGS_PATH' file" 1>&2
    exit 1
fi

read -r -p "Enter the host (e.g. wiki.example.com): " MEDIAWIKI_HOST
read -r -p "Enter the ACME email: " ACME_EMAIL

read -r -p "Do you want to manually enter your database password? (y/n) " YN
if [[ "$YN" == y ]]; then
    read -r -p "Enter the database password: " MYSQL_PASSWORD
else
    MYSQL_PASSWORD=$(date '+%Y%m%d_%H%M%S' | sha256sum | awk '{print $1}')
fi

ENV="
MEDIAWIKI_HOST=$MEDIAWIKI_HOST
ACME_EMAIL=$ACME_EMAIL
MYSQL_PASSWORD=$MYSQL_PASSWORD
"

REPORT="
Go to page https://$MEDIAWIKI_HOST/mw-config/index.php and continue setting:

Connect to database:
 - Database type: MariaDB, MySQL, or compatible
 - Database host: mariadb
 - Database name: my_wiki
 - Database table prefix: wiki
 - Database username: wikiuser
 - Database password: $MYSQL_PASSWORD
Name:
 - Name of wiki: osom
 - Project namespace: Select 'Same as the wiki name:'
 Administrator account:
  - Your username: $USER
  - Password: ****
  - Password again: ****
  - Email address: $ACME_EMAIL
 - Select 'Ask me more questions.'
Options:
 - User rights profile: 'Private wiki'
 - Copyright and license: 'No license footer'
 Email settings:
  - Enable outbound email: disable
 Skins:
  - [v] MinervaNeue
  - [v] MonoBook
  - [v] Timeless
  - [v] Vector - Select 'Use this skin as default'
 Extensions:
  Special pages:
   - [ ] CiteThisPage
   - [ ] Interwiki
   - [ ] Nuke
   - [v] Renameuser
   - [ ] ReplaceText
  Editors:
   - [v] CodeEditor (requires WikiEditor)
   - [ ] VisualEditor
   - [v] WikiEditor
  Parser hooks:
   - [ ] CategoryTree
   - [v] Cite
   - [ ] ImageMap
   - [ ] InputBox
   - [v] Math
   - [ ] ParserFunctions
   - [ ] Poem
   - [ ] Scribunto
   - [v] SyntaxHighlight_GeSHi
   - [ ] TemplateData
  Media handlers:
   - [v] PdfHandler
  Spam prevention:
   - [ ] AbuseFilter
   - [v] ConfirmEdit
   - [ ] SpamBlacklist
   - [ ] TitleBlacklist
  API:
   - [ ] PageImages
  Other:
   - [ ] Gadgets
   - [v] MultimediaViewer
   - [ ] OATHAuth
   - [ ] SecureLinkFixer
   - [ ] TextExtracts
 Images and file uploads:
  - [v] Enable file uploads
  - [ ] Enable Instant Commons
 Personalization:
  - Logo (icon): \$wgResourceBasePath/resources/assets/logo.png
  - Sidebar logo (optional): \$wgResourceBasePath/resources/assets/logo.png
 Advanced configuration:
  - Select 'PHP object caching (APC, APCu or WinCache)'

Add the following PHP code manually:
  require_once \"\$IP/ExtraSettings.php\";
"

echo "$ENV" > "$ENV_PATH"
echo "<?php" > "$LOCAL_SETTINGS_PATH"
echo "$REPORT"
