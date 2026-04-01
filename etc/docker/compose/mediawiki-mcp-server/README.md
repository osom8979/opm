# MediaWiki MCP Server (Docker Compose)

MediaWiki MCP Server를 StreamableHTTP 모드로 상시 기동합니다.
GitHub에서 소스를 clone하여 빌드하므로 외부 디렉토리 참조가 필요 없습니다.

## 설정

```bash
# 1. .env 및 config.json 생성
./generate-env

# 2. config.json에서 위키 설정 편집
vi config.json

# 3. 빌드 및 기동
docker compose up -d --build

# 4. 상태 확인
docker compose ps
curl http://localhost:8090/health
```

## Claude Code에서 연결

`~/.claude/settings.json` 또는 프로젝트의 `.mcp.json`에 추가:

```json
{
  "mcpServers": {
    "mediawiki": {
      "url": "http://<서버IP>:8090/mcp"
    }
  }
}
```

## 관리

```bash
docker compose logs -f          # 로그 확인
docker compose restart          # 재시작
docker compose down             # 중지
docker compose up -d --build    # 재빌드 후 기동
```
