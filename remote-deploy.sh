#!/bin/bash

# 部署脚本 - 在远程服务器上执行

set -e

APP_DIR="/home/bxn818204/miniyum-lark"
PORT=3001

echo "=========================================="
echo "miniyum-Lark 服务器部署开始"
echo "=========================================="
echo ""

# 1. 创建应用目录
echo "[1/8] 创建应用目录..."
mkdir -p $APP_DIR
cd $APP_DIR

# 2. 克隆或更新代码
echo "[2/8] 获取最新代码..."
if [ -d ".git" ]; then
    echo "  → 更新现有仓库..."
    git fetch origin
    git reset --hard origin/master
else
    echo "  → 克隆新仓库..."
    git clone https://github.com/bxn818204/miniyum-Lark.git . 2>/dev/null || true
fi

# 3. 创建 .env 文件
echo "[3/8] 配置环境变量..."
cat > .env << 'ENVEOF'
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
PORT=3001
ENVEOF
chmod 600 .env
echo "  → .env 文件已创建"

# 4. 检查 Docker
echo "[4/8] 检查 Docker..."
if command -v docker &> /dev/null; then
    echo "  → Docker 已安装: $(docker --version)"
else
    echo "  ✗ Docker 未安装，尝试安装..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    sudo usermod -aG docker $(whoami)
    echo "  ℹ 请重新登录以应用 docker 组权限"
fi

# 5. 检查 docker-compose
echo "[5/8] 检查 docker-compose..."
if command -v docker-compose &> /dev/null; then
    echo "  → docker-compose 已安装: $(docker-compose --version)"
else
    echo "  ✗ docker-compose 未安装，尝试安装..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "  → docker-compose 安装完成"
fi

# 6. 停止旧容器
echo "[6/8] 清理旧容器..."
docker-compose down 2>/dev/null || true

# 7. 启动新服务
echo "[7/8] 启动新服务 (端口 $PORT)..."
docker-compose up -d --build 2>&1 | tail -5

# 8. 验证服务
echo "[8/8] 验证服务状态..."
sleep 3

if docker ps | grep -q miniyum; then
    echo ""
    echo "=========================================="
    echo "✅ 部署成功！"
    echo "=========================================="
    echo ""
    echo "应用信息："
    echo "  应用目录: $APP_DIR"
    echo "  服务端口: $PORT"
    echo "  访问地址: http://localhost:$PORT"
    echo ""
    echo "容器状态:"
    docker ps --filter "name=miniyum" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "查看日志命令:"
    echo "  cd $APP_DIR && docker-compose logs -f"
    echo ""
else
    echo "⚠️ 容器启动可能失败,请检查日志:"
    docker-compose logs --tail 20
fi
