# SSL 인증서 생성 (Redis)

Redis는 TLS 전용 포트로 실행되며, 인증서가 없으면 컨테이너가 정상 동작하지 않습니다.

## 자동 생성 (권장)

`infra/redis/`에서 아래를 실행하면 인증서 생성 컨테이너가 먼저 실행된 뒤 Redis가 시작됩니다.

```bash
docker compose up -d
```

## 수동 생성

```bash
cd infra/redis/ssl
chmod +x generate-certs.sh
./generate-certs.sh
```

## 생성된 파일

- `redis-ca.pem`: Redis CA 인증서 (클라이언트 연결 시 필요)
- `redis-cert.pem`: Redis 서버 인증서
- `redis-key.pem`: Redis 서버 개인키

## 주의사항

- 인증서는 `infra/redis/ssl/` 디렉토리에 생성됩니다.
- `.gitignore`에 의해 Git에 커밋되지 않습니다.
- TLS 접속을 위해 애플리케이션에서 `redis-ca.pem`을 신뢰하도록 설정해야 합니다.

