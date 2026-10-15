# infra

로컬 개발용 PostgreSQL과 Redis입니다. 접속 정보는 개발 전용이며 운영 환경에서는 사용하지 않습니다.

```bash
docker compose -f infra/docker-compose.yml up -d
docker compose -f infra/docker-compose.yml down
```

| 서비스 | 주소 | 계정 |
|---|---|---|
| PostgreSQL | `localhost:5432/hush` | `hush` / `hush` |
| Redis | `localhost:6379` | 없음 |
