#!/bin/bash
set -e

cd ~
rm -rf miniyum-lark 2>/dev/null
mkdir -p miniyum-lark
cd miniyum-lark

echo "[1/6] 下载代码..."
wget -q -O master.tar.gz https://github.com/bxn818204/miniyum-Lark/archive/master.tar.gz
tar -xzf master.tar.gz
mv miniyum-Lark-master/* .
rm -rf miniyum-Lark-master master.tar.gz

echo "[2/6] 配置环境变量..."
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
PORT=3001
EOF

echo "[3/6] 停止旧容器..."
docker-compose down 2>/dev/null || true

echo "[4/6] 开放防火墙..."
sudo ufw allow 3001/tcp 2>/dev/null || true

echo "[5/6] 启动新服务..."
docker-compose up -d --build

echo "[6/6] 等待启动..."
sleep 3

echo ""
echo "=========================================="
echo "✅ 部署完成！"
echo "=========================================="
echo ""
docker-compose ps
echo ""
echo "检查容器日志..."
docker-compose logs --tail 30
echo ""
echo "服务URL: http://localhost:3001"
