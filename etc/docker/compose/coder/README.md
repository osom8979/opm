# Coder (Docker Compose)

셀프 호스팅 개발 환경 플랫폼인 [Coder](https://github.com/coder/coder) 를
**PostgreSQL** 백엔드와 함께 기동한다.

## 구성

- **coder-server**
  Coder 서버(웹 UI + API). 기본 포트는 `7080`.
- **coder-postgres**
  워크스페이스/템플릿/사용자 등의 메타데이터 저장소.

Docker 템플릿으로 워크스페이스를 만들기 위해 호스트의
`/var/run/docker.sock` 을 마운트하며, `group_add` 로 호스트의 `docker` 그룹
GID 를 부여한다.

## 설정

```bash
# 1. .env 생성 (POSTGRES_PASSWORD, DOCKER_GID, CODER_ACCESS_URL 자동 설정)
./generate-env

# 2. 필요하면 .env 편집 (특히 CODER_ACCESS_URL)
vi .env

# 3. 기동
docker compose up -d

# 4. 상태 확인
docker compose ps
curl http://localhost:7080/healthz
```

### CODER_ACCESS_URL

워크스페이스(에이전트)가 서버로 되돌아 접속할 때 사용하는 주소이므로
`localhost` 나 `127.0.0.1` 은 사용할 수 없다. `generate-env` 는 기본값으로
`http://$(hostname):7080` 을 사용한다. 외부에서 접근해야 한다면 실제 도메인이나
IP 로 수정한다.

```env
CODER_ACCESS_URL=http://192.168.0.10:7080
```

## 첫 관리자 계정 생성

브라우저에서 `CODER_ACCESS_URL` 로 접속하면 최초 관리자 계정 생성 화면이
나온다. CLI 로 만들려면:

```bash
docker compose exec coder coder login http://localhost:7080
```

## 관리

```bash
docker compose logs -f coder      # 로그 확인
docker compose logs -f postgres
docker compose restart            # 재시작
docker compose down               # 중지
docker compose down -v            # 볼륨 포함 초기화
```

## 참고

- 공식 Compose: <https://github.com/coder/coder/blob/main/compose.yaml>
- 문서: <https://coder.com/docs>
- 템플릿: <https://registry.coder.com/templates>
