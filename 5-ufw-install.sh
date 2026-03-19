#!/bin/bash
set -e

echo "=== 1. UFW 설치 ==="
sudo apt update
sudo apt install -y ufw

echo ""
echo "=== 2. 기본 정책 설정 ==="
sudo ufw default deny incoming
sudo ufw default allow outgoing

echo ""
echo "=== 3. SSH 허용 (잠금 방지) ==="
sudo ufw allow 22/tcp

echo ""
echo "=== 4. Redis 포트 허용 (6379 - 호스트 서버만) ==="
sudo ufw allow from 192.168.45.68 to any port 6379 proto tcp

echo ""
echo "=== 5. Bull-Board 포트 허용 (3000 - 호스트 서버만) ==="
sudo ufw allow from 192.168.45.68 to any port 3000 proto tcp

echo ""
echo "=== 6. UFW 활성화 ==="
sudo ufw --force enable

echo ""
echo "=== 7. Docker와 UFW 충돌 방지 설정 ==="
# Docker는 iptables를 직접 조작하여 UFW 규칙을 우회함
# DOCKER_OPTS에 --iptables=false 대신, /etc/ufw/after.rules에 규칙 추가
if ! grep -q "DOCKER-USER" /etc/ufw/after.rules 2>/dev/null; then
  sudo tee -a /etc/ufw/after.rules > /dev/null << 'RULES'

# Docker UFW 충돌 방지: 외부에서 Docker 컨테이너로의 직접 접근 차단
*filter
:DOCKER-USER - [0:0]
# 호스트 서버(192.168.45.68)에서 컨테이너 접근 허용
-A DOCKER-USER -s 192.168.45.68 -j ACCEPT
# 로컬호스트에서 컨테이너 접근 허용
-A DOCKER-USER -s 127.0.0.0/8 -j ACCEPT
# Docker 내부 네트워크 허용 (컨테이너 간 통신)
-A DOCKER-USER -s 172.16.0.0/12 -j ACCEPT
# 이미 연결된 세션 유지
-A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# 나머지 외부 접근 차단
-A DOCKER-USER -j DROP
COMMIT
RULES
  echo "Docker UFW 규칙 추가 완료."
else
  echo "Docker UFW 규칙이 이미 존재합니다."
fi

echo ""
echo "=== 8. UFW 재시작 ==="
sudo ufw reload

echo ""
echo "=== 설정 완료 ==="
sudo ufw status verbose
