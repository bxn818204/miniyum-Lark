#!/bin/bash
# miniyum-Lark 一键部署脚本
# 使用方法：bash quick-deploy.sh

set -e

echo "=========================================="
echo "  miniyum-Lark 一键部署脚本"
echo "=========================================="
echo ""

# 1. 准备目录和代码
echo "📦 步骤 1/5: 准备代码..."
cd ~
rm -rf miniyum-lark
mkdir -p miniyum-lark
cd miniyum-lark

# 使用wget下载代码
wget -q -O master.tar.gz https://github.com/bxn818204/miniyum-Lark/archive/refs/heads/master.tar.gz
tar -xzf master.tar.gz
mv miniyum-Lark-master/* .
rm -rf miniyum-Lark-master master.tar.gz
echo "✓ 代码准备完成"

# 2. 配置环境变量
echo ""
echo "⚙️  步骤 2/5: 配置环境变量..."
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
PORT=3001
EOF
echo "✓ 环境变量配置完成"

# 3. 停止旧容器
echo ""
echo "🛑 步骤 3/5: 停止旧容器..."
docker-compose down 2>/dev/null || echo "没有运行中的容器"

# 4. 构建并启动新容器
echo ""
echo "🚀 步骤 4/5: 构建并启动容器..."
docker-compose up -d --build

# 5. 等待容器启动
echo ""
echo "⏳ 步骤 5/5: 等待容器启动..."
sleep 5

# 显示结果
echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="
echo ""
echo "📊 容器状态："
docker ps | grep -E "CONTAINER|feishu"
echo ""
echo "📝 最近日志："
docker logs --tail 20 feishu-deepseek-bot
echo ""
echo "=========================================="
echo "✅ Webhook URL: http://www.woaixiaoyu.xyz:3001/webhook"
echo "=========================================="
echo ""
echo "常用命令："
echo "  查看日志: docker logs -f feishu-deepseek-bot"
echo "  重启容器: docker-compose restart"
echo "  停止容器: docker-compose down"
echo ""
