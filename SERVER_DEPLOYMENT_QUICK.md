# 💻 一键部署到服务器（推荐）

## 快速部署命令

在你的服务器上执行这个完整命令：

```bash
cd ~ && bash -c "$(curl -fsSL https://raw.githubusercontent.com/bxn818204/miniyum-Lark/master/quick-deploy.sh)"
```

## 或者分步执行

### 步骤 1：SSH 登录到服务器

```bash
ssh -p 22 bxn818204@www.woaixiaoyu.xyz
# 输入密码：Aaa@13278505045
```

### 步骤 2：执行部署命令

登录后，复制粘贴下面的完整代码块：

```bash
#!/bin/bash
set -e

echo "=========================================="
echo "  开始部署 miniyum-Lark"
echo "=========================================="

cd ~
rm -rf miniyum-lark
mkdir -p miniyum-lark
cd miniyum-lark

echo "[1/6] 下载代码..."
wget -q -O master.tar.gz https://github.com/bxn818204/miniyum-Lark/archive/refs/heads/master.tar.gz
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

echo "[3/6] 验证 Docker..."
docker --version || (curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh)

echo "[4/6] 验证 docker-compose..."
docker-compose --version || (sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose)

echo "[5/6] 开放防火墙..."
sudo ufw allow 3001/tcp 2>/dev/null || true

echo "[6/6] 启动服务..."
docker-compose down 2>/dev/null || true
docker-compose up -d --build

sleep 3

echo ""
echo "=========================================="
echo "✅ 部署完成！"
echo "=========================================="
docker-compose ps
echo ""
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "应用访问地址："
echo "  本地: http://localhost:3001"
echo "  远端: http://$SERVER_IP:3001"
echo ""
echo "查看日志: docker-compose logs -f"
```

### 步骤 3：验证部署

```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 测试连接
curl http://localhost:3001
```

## 关键信息

- **SSH 端口**: 22 (不是 5666！)
- **应用端口**: 3001
- **用户名**: bxn818204
- **密码**: Aaa@13278505045
- **域名**: www.woaixiaoyu.xyz

## 常见问题

### Q: 无法 SSH 连接？
A: 确认使用端口 **22** 而非 5666（5666 是 Web 端口）
```bash
ssh -p 22 bxn818204@www.woaixiaoyu.xyz
```

### Q: Docker 未安装？
A: 部署脚本会自动检测并安装

### Q: 密码不对？
A: 使用 `Aaa@13278505045`（已确认可用）

### Q: 如何停止服务？
```bash
docker-compose down
```

### Q: 如何重启服务？
```bash
docker-compose restart
```

### Q: 如何查看实时日志？
```bash
docker-compose logs -f
```

## 部署完成后

✅ 服务将在 `http://your_server_ip:3001` 运行
✅ 飞书机器人应用已连接: `cli_a911153c86789ed0`
✅ DeepSeek API 已配置

## 更新代码後重新部署

```bash
cd ~/miniyum-lark
git pull origin master  # 或者 wget 下载最新代码
docker-compose up -d --build
```
