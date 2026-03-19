#!/bin/sh
set -e

# Windows에서도 docker-compose로 실행될 수 있도록 POSIX sh로 작성

SSL_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SSL_DIR"

if [ -f "redis-ca.pem" ] && [ -f "redis-cert.pem" ] && [ -f "redis-key.pem" ]; then
  echo "Redis SSL 인증서가 이미 존재합니다. (재생성 생략)"
  exit 0
fi

echo "Redis SSL 인증서 생성 시작..."

# CA 인증서 생성
openssl genrsa 2048 > redis-ca-key.pem
openssl req -new -x509 -nodes -days 3650 \
  -key redis-ca-key.pem \
  -out redis-ca.pem \
  -subj "/C=KR/O=Jumsim/CN=Redis-CA"

# Redis 서버 인증서 생성
# SAN:
# - VPN/내부망에서 접속 시 사용하는 사설 IP(예: 192.168.45.64)
# - 컨테이너 이름(redis), localhost 포함
openssl req -newkey rsa:2048 -nodes \
  -keyout redis-key.pem \
  -out redis-req.pem \
  -subj "/C=KR/O=Jumsim/CN=redis" \
  -addext "subjectAltName=IP:192.168.45.64,DNS:redis,DNS:localhost"

openssl x509 -req -days 3650 \
  -in redis-req.pem \
  -CA redis-ca.pem \
  -CAkey redis-ca-key.pem \
  -CAcreateserial \
  -copy_extensions copyall \
  -out redis-cert.pem

# 권한 설정(컨테이너 환경 기준)
chmod 600 redis-ca-key.pem redis-key.pem || true
chmod 644 redis-ca.pem redis-cert.pem || true

# 임시 파일 정리
rm -f redis-req.pem *.srl

echo "Redis SSL 인증서 생성 완료"
echo ""
echo "생성된 파일:"
ls -la *.pem || true
echo ""
echo "Redis: redis-cert.pem, redis-key.pem"
echo "클라이언트 연결 시 redis-ca.pem 파일을 사용하세요."

