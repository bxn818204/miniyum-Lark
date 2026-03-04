#!/bin/bash

# miniyum-Lark 服务器部署脚本
# 用途：快速部署应用到3001端口

set -e

APP_DIR="/opt/miniyum-lark"
PORT=3001

echo "=== miniyum-Lark 部署开始 ==="

# 1. 创建应用目录
mkdir -p $APP_DIR
cd $APP_DIR

# 2. 克隆或更新代码
if [ -d ".git" ]; then
    echo "更新现有代码..."
    git pull origin master
else
    echo "克隆代码仓库..."
    git clone https://github.com/bxn818204/miniyum-Lark.git . || git clone git@github.com:bxn818204/miniyum-Lark.git .
fi

# 3. 创建 .env 文件
echo "配置环境变量..."
cat > .env << 'ENVEOF'
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
PORT=3001
ENVEOF

# 4. 检查 Docker 和 docker-compose
if ! command -v docker &> /dev/null; then
    echo "正在安装 Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
fi

if ! command -v docker-compose &> /dev/null; then
    echo "正在安装 docker-compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# 5. 停止旧容器
echo "停止旧容器..."
docker-compose down 2>/dev/null || true

# 6. 启动新服务
echo "启动新服务 (端口 $PORT)..."
docker-compose up -d --build

# 7. 等待服务启动
sleep 3

# 8. 验证服务
echo "验证服务状态..."
docker ps | grep miniyum-lark || echo "警告：容器可能未正确启动"

# 9. 显示日志
echo ""
echo "=== 最近日志 ==="
docker-compose logs --tail 20 || true

echo ""
echo "=== 部署完成 ==="
echo "服务在端口 $PORT 上运行"
echo "应用URL: http://localhost:3001"
