# 手动部署步骤（在你的服务器上执行）

## 步骤 1：创建应用目录

```bash
mkdir -p ~/miniyum-lark
cd ~/miniyum-lark
```

## 步骤 2：克隆最新代码

```bash
git clone https://github.com/bxn818204/miniyum-Lark.git .
```

如果已经有仓库，更新代码：
```bash
git pull origin master
```

## 步骤 3：创建 .env 配置文件

```bash
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
PORT=3001
EOF
```

验证文件创建成功：
```bash
cat .env
```

## 步骤 4：检查 Docker 和 docker-compose

### 检查 Docker
```bash
docker --version
```

如果未安装 Docker：
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $(whoami)
```

### 检查 docker-compose
```bash
docker-compose --version
```

如果未安装 docker-compose：
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 步骤 5：（可选）开放防火墙端口

如果使用 UFW：
```bash
sudo ufw allow 3001/tcp
sudo ufw status
```

如果使用其他防火墙，确保允许 3001 端口入站。

## 步骤 6：启动服务

```bash
cd ~/miniyum-lark
docker-compose down  # 停止旧服务（如果有）
docker-compose up -d --build
```

等待 2-3 秒容器启动...

## 步骤 7：验证部署

### 查看容器运行状态
```bash
docker ps | grep miniyum
```

应该看到运行中的 miniyum 容器，并显示端口 3001

### 查看服务日志
```bash
docker-compose logs -f
```

按 `Ctrl+C` 退出日志查看

### 测试服务是否响应
```bash
curl http://localhost:3001
```

## 步骤 8：后续维护

### 查看运行状态
```bash
cd ~/miniyum-lark
docker-compose ps
```

### 查看实时日志
```bash
docker-compose logs -f
```

### 停止服务
```bash
docker-compose down
```

### 重启服务
```bash
docker-compose restart
```

### 更新代码后重新部署
```bash
cd ~/miniyum-lark
git pull origin master
docker-compose up -d --build
```

## 完整部署命令（一键执行）

复制整个代码块，在服务器上粘贴执行：

```bash
#!/bin/bash
set -e

# 创建目录
mkdir -p ~/miniyum-lark
cd ~/miniyum-lark

# 克隆代码
git clone https://github.com/bxn818204/miniyum-Lark.git . 2>/dev/null || git pull origin master

# 创建配置
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
PORT=3001
EOF

# 开放端口
sudo ufw allow 3001/tcp 2>/dev/null || true

# 启动服务
docker-compose down 2>/dev/null || true
docker-compose up -d --build

# 等待启动
sleep 3

# 显示状态
echo "========== 部署完成 =========="
docker ps | grep miniyum || echo "⚠️ 容器未能启动"
echo "查看日志: docker-compose logs -f"
```

## 故障排查

### 容器无法启动
```bash
docker-compose logs
```

### 端口已被占用
```bash
sudo lsof -i :3001
sudo fuser -k 3001/tcp
```

### 权限问题
```bash
sudo usermod -aG docker $(whoami)
# 注销并重新登录
```

### 代码有问题
```bash
cd ~/miniyum-lark
git status  # 查看状态
git log --oneline -5  # 查看最后5个提交
```

## 服务地址

部署完成后，访问：
- **本地访问**: http://localhost:3001
- **远程访问**: http://your_server_ip:3001

其中 `your_server_ip` 是你服务器的实际 IP 地址。
