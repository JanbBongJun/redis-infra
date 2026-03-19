#!/bin/bash
set -e

echo "=== 1. 기존 Docker 패키지 제거 ==="
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt remove -y $pkg 2>/dev/null || true
done

echo "=== 2. apt 저장소 설정 ==="
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

echo "=== 3. Docker Engine 설치 ==="
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== 4. Docker 서비스 시작 및 자동 시작 등록 ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== 5. 현재 사용자 docker 그룹 추가 ==="
sudo usermod -aG docker $USER

echo "=== 6. Elasticsearch용 vm.max_map_count 설정 ==="
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "=== 7. 공유 Docker 네트워크 생성 ==="
docker network create jumsim_network 2>/dev/null || echo "jumsim_network 이미 존재합니다."

echo ""
echo "=== 설치 완료 ==="
docker --version
docker compose version
echo ""
echo "※ docker 그룹 적용을 위해 터미널을 재접속하거나 아래 명령 실행:"
echo "   newgrp docker"