#!/bin/bash
set -e

cd ~/miniyum-lark

echo "========== 部署开始 =========="
echo ""

# 列出文件
echo "[1/4] 检查代码..."
ls -lh | head -10

# 检查 .env
echo ""
echo "[2/4] 验证配置..."
if [ -f .env ]; then
    echo "✓ .env 文件存在"
    cat .env
else
    echo "✗ .env 文件不存在！"
    exit 1
fi

# 检查 docker-compose
echo ""
echo "[3/4] 检查 Docker..."
docker --version
docker-compose --version

# 启动服务
echo ""
echo "[4/4] 启动服务（端口 3001）..."
docker-compose down 2>/dev/null || echo "No existing containers"
docker-compose up -d --build

echo ""
sleep 3

echo "========== 部署完成 =========="
echo ""
echo "容器状态："
docker-compose ps
echo ""
echo "检查日志（最后20行）："
docker-compose logs --tail 20
echo ""
echo "应用地址: http://localhost:3001"
