#!/bin/bash
set -e

echo "=== 1. SSH 키 생성 ==="
read -p "GitHub 이메일 주소를 입력하세요: " GH_EMAIL

if [ -f ~/.ssh/id_ed25519 ]; then
  echo "SSH 키가 이미 존재합니다. 기존 키를 사용합니다."
else
  ssh-keygen -t ed25519 -C "$GH_EMAIL" -f ~/.ssh/id_ed25519 -N ""
  echo "SSH 키 생성 완료."
fi

echo ""
echo "=== 2. ssh-agent 시작 및 키 등록 ==="
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

echo ""
echo "=== 3. GitHub에 등록할 공개 키 ==="
echo "────────────────────────────────────────"
cat ~/.ssh/id_ed25519.pub
echo ""
echo "────────────────────────────────────────"
echo ""
echo "위 공개 키를 복사하여 GitHub에 등록하세요:"
echo "  https://github.com/settings/ssh/new"
echo ""

read -p "GitHub에 키를 등록한 후 Enter를 누르세요..."

echo ""
echo "=== 4. GitHub 연결 테스트 ==="
ssh -T git@github.com || true

echo ""
echo "=== 5. Git 사용자 정보 설정 ==="
read -p "Git 사용자 이름을 입력하세요: " GIT_NAME
git config --global user.name "$GIT_NAME"
git config --global user.email "$GH_EMAIL"


echo ""
echo "=== 설정 완료 ==="
echo "user.name  : $(git config --global user.name)"
echo "user.email : $(git config --global user.email)"
