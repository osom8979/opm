# Self-hosted MediaWiki

공식 [MediaWiki Docker 이미지](https://hub.docker.com/_/mediawiki)로 구성한
셀프 호스팅 위키. Traefik 이 HTTPS(Let's Encrypt)를 처리하고 MariaDB 에
데이터를 저장한다.

## 구성

| 서비스 | 이미지 | 역할 | 상태 저장 위치 |
|---|---|---|---|
| `traefik` | `traefik:v2.10` | 443 TLS 종료, 인증서 자동 발급 | `letsencrypt/` |
| `mariadb` | `mariadb:11.0.2` | 위키 DB (`my_wiki`, 테이블 접두사 `wiki`) | `mysql/` |
| `mediawiki` | `mediawiki:1.43.11` | Apache + mod_php (PHP 8.3) | `images/`, `LocalSettings.php` |

MediaWiki 이미지는 PHP 를 포함하므로 PHP 버전은 이미지 태그로 결정된다.
같은 태그도 PHP 보안 패치 때 다시 빌드되므로 `docker compose pull` 로 갱신한다.

## 파일

| 파일 | 설명 |
|---|---|
| `docker-compose.yml` | 서비스 정의 |
| `init.php` | `LocalSettings.php` 의 템플릿 (확장, 업로드, 권한, 2단계 인증 설정) |
| `phpconfig.ini` | PHP 설정 (업로드 256M, 메모리 512M) |
| `logo.png` | 위키 로고 |
| `SimpleMathJax/` | `<math>` 렌더링 확장 (git 서브모듈) |
| `common.sh` | 스크립트 공용 함수 (직접 실행하지 않음) |
| `*.sh` | 설치/운영 스크립트 ([사용법](#스크립트-사용법)) |

git 에 포함되지 않는 파일:

| 파일 | 설명 |
|---|---|
| `.env` | 호스트명, ACME 이메일, DB 비밀번호 |
| `LocalSettings.php` | `init.php` + 비밀 값. 컨테이너에 읽기 전용으로 마운트 |
| `mysql/` | MariaDB 데이터 |
| `images/` | 업로드 파일. 컨테이너의 `www-data`(UID 33) 소유여야 함 |
| `letsencrypt/` | 인증서 |
| `backup/` | 백업 파일 |

## 설치

```bash
./update-submodule.sh                 # 저장소를 clone 한 뒤 한 번
bash setup.sh                         # .env, LocalSettings.php 생성 후 설치 안내 출력
mkdir -p images && sudo chown 33:33 images
docker compose up -d
```

`setup.sh` 가 출력한 안내에 따라 `https://<호스트>/mw-config/index.php` 에서
설치를 마무리한다 (DB 테이블 생성).
설치가 끝나면 관리자 계정으로 로그인해 [2단계 인증](#2단계-인증)을 등록한다.

`init.php` 를 고쳐도 기존 `LocalSettings.php` 에는 반영되지 않는다.
운영 중인 서버에서는 `LocalSettings.php` 에 같은 변경을 직접 적용한다.

```bash
diff init.php LocalSettings.php   # 끝부분의 비밀 값 외 차이 확인
```

## 2단계 인증

이미지에 포함된 [OATHAuth](https://www.mediawiki.org/wiki/Extension:OATHAuth) 확장으로 TOTP 2단계 인증을 쓴다.
TOTP 를 등록한 계정은 비밀번호로 로그인할 때마다 인증 앱의 6자리 코드를 입력해야 한다.

### 등록

1. 로그인 후 `https://<호스트>/index.php/Special:OATHManage` 로 이동한다.
2. 인증 앱(Aegis, Google Authenticator, 1Password 등)으로 QR 코드를 스캔하고 코드를 입력한다.
3. 함께 표시되는 복구 코드를 별도 장소에 보관한다. 각 코드는 한 번만 쓸 수 있다.
4. 로그인한 창은 닫지 말고, 시크릿 창에서 다시 로그인해 코드 입력 화면이 나오는지 확인한다.

설치 화면에서 OATHAuth 를 선택하지 않았다면 테이블이 없다. `./update-schema.sh` 로 만든다.

### 우회 경로 차단

`init.php` 는 로그인 화면을 거치지 않는 경로를 막는다.

| 설정 | 효과 |
|---|---|
| `$wgRememberMe = 'never'` | "로그인 상태 유지" 체크박스를 없앤다. 기본값이면 체크 시 180일 동안 다시 로그인하지 않는다. |
| `$wgEnableBotPasswords = false` | `Special:BotPasswords` 를 끈다. bot password 는 API 로그인 때 2단계 인증을 거치지 않는다. |

예외로 [create-readonly-bot.sh](#create-readonly-botsh) 가 만드는 봇 계정은 비밀번호만으로 API 에 로그인한다.
대신 `read` 외의 모든 권한을 회수하므로 비밀번호가 유출되어도 위키를 바꿀 수 없다.

브라우저를 닫거나 1시간 동안 요청이 없으면 다시 로그인해야 한다.
세션은 APCu 에 저장되므로 `mediawiki` 컨테이너를 재시작해도 로그아웃된다.
1시간이 짧으면 `$wgObjectCacheSessionExpiry` 를 초 단위로 늘린다.

### 잠겼을 때

인증 앱과 복구 코드를 모두 잃으면 위키 안에서는 해제할 수 없다.
`mariadb` 가 떠 있는 상태에서 서버에서 해당 사용자의 2단계 인증을 지운다.

```bash
docker compose run --rm --no-deps --user www-data mediawiki \
    php extensions/OATHAuth/maintenance/disableOATHAuthForUser.php <사용자명>
```

`maintenance/run.php OATHAuth:disableOATHAuthForUser` 형식은 1.43 에서 클래스 중복 오류가 나므로 스크립트를 직접 실행한다.
다른 sysop 계정이 있다면 `Special:DisableOATHForUser` 로도 해제할 수 있다.

## 스크립트 사용법

| 스크립트 | 용도 | sudo | 서비스 중단 |
|---|---|---|---|
| `setup.sh` | 최초 설정 파일 생성 | | |
| `update-submodule.sh` | SimpleMathJax 서브모듈을 기록된 커밋으로 맞춤 | | |
| `update-schema.sh` | MediaWiki 업그레이드나 확장 추가 후 DB 스키마 갱신 | | |
| `run-jobs.sh` | 작업 큐 처리 | | |
| `version.sh` | 이미지/MediaWiki/PHP 버전과 컨테이너 상태 확인 | | |
| `create-readonly-bot.sh` | unwiki 용 읽기 전용 봇 계정 생성, 비밀번호 재발급 | | |
| `backup-raw.sh` | DB 파일 그대로 백업 (복원이 가장 빠름) | ✅ | ✅ 백업 동안 |
| `backup-dump.sh` | SQL 덤프 백업 (무중단, cron 용) | ✅ | |
| `verify-backup.sh` | 백업을 임시 DB 에 띄워 검사 | ✅ | |
| `restore-raw.sh` | raw 백업으로 복원 (롤백) | ✅ | ✅ |

모든 스크립트는 어느 디렉터리에서 실행해도 자기 위치의 `docker-compose.yml` 을 사용한다.

### update-submodule.sh

```bash
./update-submodule.sh
```

`git pull` 뒤에 실행한다. 서브모듈을 저장소에 기록된 커밋으로 체크아웃한다.
upstream 최신 커밋으로 올리는 것이 아니다.

### update-schema.sh

```bash
./update-schema.sh
```

MediaWiki 이미지를 올린 뒤 `maintenance/run.php update --quick` 을 실행한다.
`mariadb` 가 떠 있어야 하며, 웹 컨테이너와 별개의 일회성 컨테이너에서 `www-data` 로 실행된다.
인자는 그대로 전달된다 (예: `./update-schema.sh --skip-external-dependencies`).

### run-jobs.sh

```bash
./run-jobs.sh
./run-jobs.sh --maxjobs 100
```

작업 큐(링크 갱신, 썸네일 등)를 비운다. 백업과 업그레이드 전후에 실행한다.
`mariadb` 만 떠 있으면 되고, 1.39 이하에서는 `runJobs.php` 를 직접 실행한다.

### version.sh

```bash
./version.sh
```

```text
[mediawiki]
  image     : mediawiki:1.43.11
  built     : 2026-10-21T17:53:00.582896984Z
  container : running
  MediaWiki : 1.43.11
  PHP       : 8.3.36
```

`container` 가 `running an older image` 이면 새로 받은 이미지가 아직 적용되지 않은 것이다.
`docker compose up -d` 로 컨테이너를 다시 만든다.
PHP 보안 공지가 나오면 `PHP` 값으로 패치 여부를 확인한다.

### create-readonly-bot.sh

```bash
./create-readonly-bot.sh              # 계정 이름 UnwikiBot
./create-readonly-bot.sh OtherBot
```

[unwiki](https://github.com/osom8979/unwiki) 의 mwfilter 가 문서를 내려받을 때 쓰는 읽기 전용 계정을 만든다.
bot password 를 껐으므로 봇은 일반 계정 비밀번호로 API 에 로그인한다.
그래서 계정을 `readonly` 그룹에 넣고 `read` 외의 권한을 모두 회수한다.

먼저 `init.php` 의 `Read-only accounts` 블록을 `LocalSettings.php` 끝에 추가한다.
블록이 없거나 `read` 외 권한이 남아 있으면 남은 권한을 출력하고 계정을 만들지 않는다.
확장을 새로 켜면 그 확장이 `user` 그룹에 주는 권한도 `$wgRevokePermissions['readonly']` 에 추가해야 한다.

`mariadb` 가 떠 있어야 하며 다음을 출력한다.

```text
Created read-only account 'UnwikiBot' (rights: read).

Add the following to unwiki's .env.local:

MEDIAWIKI_HOSTNAME=wiki.example.com
MEDIAWIKI_USERNAME=UnwikiBot
MEDIAWIKI_PASSWORD=<40자리 16진수>
ENDPOINT_PATH=/

Account management (log in as an administrator):
 - Groups       : https://wiki.example.com/index.php/Special:UserRights/UnwikiBot
 - Group rights : https://wiki.example.com/index.php/Special:ListGroupRights
 - Members      : https://wiki.example.com/index.php/Special:ListUsers/readonly
 - Edits        : https://wiki.example.com/index.php/Special:Contributions/UnwikiBot
 - Logs         : https://wiki.example.com/index.php/Special:Log?page=User:UnwikiBot
```

`ENDPOINT_PATH` 는 `MEDIAWIKI_*` 가 아니지만 함께 넣는다.
mwfilter 의 기본값은 `/w/` 인데 이 위키는 `api.php` 가 `/` 아래에 있다.

- 비밀번호는 컨테이너 안에서 만들어 한 번만 출력한다. `ps` 에 나타나지 않는다.
- 같은 계정으로 다시 실행하면 새 비밀번호를 발급하고 이전 비밀번호는 바로 쓸 수 없다.
- `readonly` 그룹이 아닌 기존 계정은 사람 계정일 수 있으므로 비밀번호를 바꾸지 않고 중단한다.
- `readonly` 그룹에서 빼면 편집, 업로드 같은 일반 사용자 권한이 생긴다. 그룹을 유지한다.
- 차단해도 읽기는 막히지 않는다. 비밀번호가 유출되면 스크립트를 다시 실행한다.
- 2단계 인증을 등록하면 API 로그인이 실패한다. `oathauth-enable` 권한도 회수되어 있다.

웹 서버는 사용자 정보를 APCu 에 최대 1시간 캐시하고, 유지보수 컨테이너는 이 캐시를 지울 수 없다.
최근 1시간 안에 로그인한 계정의 비밀번호를 바꾸면 캐시가 만료될 때까지 이전 세션이 살아 있다.
그동안 새 비밀번호로 로그인하면 첫 요청 뒤 세션이 끊긴다.
바로 적용하려면 `docker compose restart mediawiki` 를 실행한다. 모든 사용자가 로그아웃된다.

### 백업 비밀번호

백업/복원/검증 스크립트는 7z 암호를 다음 순서로 찾는다.

1. 환경 변수 `BACKUP_PASSWORD`
2. 환경 변수 `BACKUP_PASSWORD_FILE` 이 가리키는 파일의 첫 줄
3. 둘 다 없으면 입력 프롬프트 (백업 시 두 번 입력)

비밀번호를 잃으면 백업을 복구할 수 없다. 별도로 보관한다.

### backup-raw.sh

```bash
sudo ./backup-raw.sh
# -> backup/raw-YYYYMMDD-HHMMSS.tar.7z, backup/raw-YYYYMMDD-HHMMSS.tar.7z.sha256
```

1. 실행 중이던 `mediawiki`, `mariadb` 를 멈춘다 (실행 중인 DB 파일을 복사하면 일관성이 깨진다).
2. `mysql/`, `images/`, `LocalSettings.php`, `.env` 를 하나의 암호화 아카이브로 만든다.
3. 멈췄던 서비스만 다시 시작한다. 실패해도 다시 시작한다.

복원이 가장 빠르므로 업그레이드 직전에 쓴다.
단, 백업한 MariaDB 버전으로만 열 수 있다.

### backup-dump.sh

```bash
sudo ./backup-dump.sh
# -> backup/dump-YYYYMMDD-HHMMSS.tar.7z, backup/dump-YYYYMMDD-HHMMSS.tar.7z.sha256
```

`mariadb-dump --single-transaction` 으로 서비스를 멈추지 않고 일관된 덤프를 뜬다.
덤프와 `images/`, `LocalSettings.php`, `.env` 를 함께 묶는다.
MariaDB 버전이 바뀌어도 복원할 수 있다. `mariadb` 가 떠 있어야 한다.

### verify-backup.sh

```bash
sudo ./verify-backup.sh backup/raw-20261022-150000.tar.7z
sudo ./verify-backup.sh backup/dump-20261022-150000.tar.7z
sudo ./verify-backup.sh mysql-20260901.7z images-20260901.7z     # 예전 형식
sudo MARIADB_IMAGE=mariadb:10.11 ./verify-backup.sh mysql-20230601.7z
```

인자 없이 실행하면 백업 목록을 보여준다.
먼저 아카이브 옆의 `.sha256` 으로 체크섬을 확인한다 (없는 예전 백업은 건너뜀).
백업을 `backup/` 아래 임시 디렉터리에 풀고, 네트워크가 없는 임시 MariaDB 컨테이너를 띄운다.

- raw: 백업의 데이터 파일로 그대로 기동한다. 깨진 파일이면 여기서 실패한다.
- dump: 빈 DB 에 덤프를 가져온다.

이어서 `mariadb-check --all-databases` 를 실행한다.
문서 수, 마지막 편집 시각, 이미지 수를 출력하므로 백업 시점이 맞는지 확인할 수 있다.
임시 컨테이너와 디렉터리는 끝나면 삭제된다.

MariaDB 이미지는 백업의 `backup.info` 를 따른다.
`backup.info` 가 없는 예전 형식은 현재 `docker-compose.yml` 의 이미지를 쓰고,
`MARIADB_IMAGE` 로 바꿀 수 있다.

### restore-raw.sh

```bash
sudo ./restore-raw.sh backup/raw-20261022-150000.tar.7z
sudo ./restore-raw.sh mysql-20260901.7z images-20260901.7z      # 예전 형식
docker compose up -d
```

1. 서비스를 멈추기 전에 아카이브를 풀어 둔다 (잘못된 비밀번호면 여기서 중단).
2. `backup.info` 의 이미지와 현재 `docker-compose.yml` 이 다르면 경고한다.
3. `yes` 를 입력하면 서비스를 멈추고 아카이브에 있는 항목만 교체한다.
4. 교체 전 항목은 `backup/before-restore-*/` 로 옮겨 둔다. 확인 후 직접 지운다.

서비스는 자동으로 시작하지 않는다. 이미지 태그를 확인한 뒤 `docker compose up -d` 한다.

### backup.sh / import.sh (XML, 예전 방식)

컨테이너 안에서 실행하는 XML 내보내기/가져오기 스크립트다.
문서 내용과 파일만 옮기고 사용자, 설정 등은 포함하지 않으므로 다른 위키로 내용을 옮길 때만 쓴다.

```bash
docker compose run --rm --no-deps \
    -v "$PWD/backup.sh:/backup.sh:ro" -v "$PWD/backup:/backup" \
    mediawiki bash /backup.sh
# -> backup/YYYYMMDD/{db,images}.tar.gz
```

## 운영 절차

### 정기 백업

```bash
sudo install -m 600 /dev/null /root/.mediawiki-backup-password
sudo vi /root/.mediawiki-backup-password
sudo crontab -e
```

```cron
0 4 * * * BACKUP_PASSWORD_FILE=/root/.mediawiki-backup-password /path/to/mediawiki/backup-dump.sh >> /var/log/mediawiki-backup.log 2>&1
30 4 * * 0 find /path/to/mediawiki/backup -name 'dump-*.tar.7z*' -mtime +30 -delete
```

`backup/` 는 원본과 같은 디스크에 있으므로 주기적으로 다른 장소에 복사한다.
`.sha256` 파일도 함께 복사하면 복사본이 온전한지 `sha256sum -c` 로 확인할 수 있다.
가끔 `verify-backup.sh` 로 실제 복원되는지 확인한다.

### 업그레이드

```bash
./version.sh                       # 현재 버전 기록
git pull && ./update-submodule.sh
diff init.php LocalSettings.php    # LocalSettings.php 에 필요한 변경 직접 반영
docker compose pull

./run-jobs.sh
docker compose stop mediawiki      # 외부 접속 차단 (backup-raw.sh 가 다시 켜지 않음)
sudo ./backup-raw.sh               # mariadb 만 멈췄다가 다시 시작
sudo ./verify-backup.sh backup/raw-<방금 만든 파일>.tar.7z

./update-schema.sh
docker compose up -d
./run-jobs.sh
./version.sh                       # 새 버전과 PHP 확인
```

업그레이드 후 로그인(2단계 인증 코드 입력 포함), 편집, 업로드, `<math>` 수식, `Special:Version` 을 확인한다.
업그레이드 전에 [Manual:Upgrading](https://www.mediawiki.org/wiki/Manual:Upgrading) 과
릴리스 노트에서 `LocalSettings.php` 변경 사항을 확인한다.

### 롤백

DB 스키마는 되돌릴 수 없으므로 이미지 태그만 되돌리면 안 된다.

```bash
git checkout <업그레이드 이전 커밋> -- docker-compose.yml SimpleMathJax
./update-submodule.sh              # 서브모듈을 위에서 되돌린 커밋으로
sudo ./restore-raw.sh backup/raw-<업그레이드 직전>.tar.7z   # DB, 이미지, 설정 복원
docker compose up -d
./version.sh
```

### 다른 서버로 이전

```bash
./update-submodule.sh              # 저장소를 clone 한 뒤
sudo ./restore-raw.sh /path/to/raw-YYYYMMDD-HHMMSS.tar.7z   # .env, LocalSettings.php 포함
docker compose up -d
```

DNS 를 새 서버로 바꾸면 Traefik 이 인증서를 새로 발급한다.

### dump 백업 복원

`dump-*.tar.7z` 는 스크립트 없이 직접 복원한다.

```bash
mkdir restore
sudo sh -c '7za x -so backup/dump-YYYYMMDD-HHMMSS.tar.7z | tar -xpf - -C restore'
docker compose up -d mariadb
sudo cat restore/database.sql | docker compose exec -T mariadb \
    sh -c 'MYSQL_PWD="$MYSQL_PASSWORD" mariadb -u"$MYSQL_USER" "$MYSQL_DATABASE"'
sudo cp -a restore/images/. images/
./update-schema.sh                 # 덤프가 이전 MediaWiki 버전이면
docker compose up -d
sudo rm -rf restore                # 비밀 값이 들어 있으므로 삭제
```

## 백업 파일 형식

| 파일 | 내용 |
|---|---|
| `backup/raw-*.tar.7z` | `backup.info`, `mysql/`, `images/`, `LocalSettings.php`, `.env` |
| `backup/dump-*.tar.7z` | `backup.info`, `database.sql`, `images/`, `LocalSettings.php`, `.env` |
| `mysql-YYYYMMDD.7z`, `images-YYYYMMDD.7z` | 예전 `backup-raw.sh` 결과. 서비스 실행 중에 복사했으므로 `verify-backup.sh` 로 확인 후 사용 |

- 7z 는 파일 소유자를 저장하지 않으므로 tar 로 묶은 뒤 7z(AES-256)로 암호화한다.
  `-mhe=on` 으로 파일 목록도 암호화된다.
- `backup.info` 에는 백업 시각과 당시 이미지 태그가 기록된다.
- 아카이브마다 `FILE.sha256` 이 함께 생성된다. 파일명만 기록하므로 두 파일이 있는 디렉터리에서 확인한다.
  비밀번호 없이 확인할 수 있다: `cd backup && sha256sum -c FILE.sha256`
- 내용 확인: `sudo 7za x -so FILE | tar -tvf -`

## 주의 사항

- 비밀번호는 `7za -p` 인자로 전달되므로 실행 중 같은 서버의 다른 사용자가 `ps` 로 볼 수 있다.
- raw 백업은 MariaDB 버전에 묶인다. MariaDB 를 올리기 전후에는 dump 백업도 함께 만든다.
- 유지보수 스크립트는 `www-data` 로 실행한다.
  root 로 실행하면 `images/` 에 웹 서버가 쓸 수 없는 파일이 생긴다.
- TOTP 코드는 서버 시계로 검증한다 (허용 오차 앞뒤 2분).
  컨테이너는 호스트 시계를 쓰므로 호스트의 NTP 동기화를 켜 둔다 (`timedatectl`).
