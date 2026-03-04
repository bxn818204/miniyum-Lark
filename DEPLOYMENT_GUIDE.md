# 部署到服务器指南

## 信息
- 服务器: www.woaixiaoyu.com (或 www.woaixiaoyu.xyz)
- 用户名: bxn818204
- 端口: 5666 (SSH)
- 应用端口: 3001
- GitHub仓库: https://github.com/bxn818204/miniyum-Lark

## 飞书应用凭证
```
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
```

## DeepSeek API
```
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
```

## 方法一：SSH + 直接命令（推荐）

### 1. SSH 登录到服务器
```bash
ssh -p 5666 bxn818204@www.woaixiaoyu.com
# 或
ssh -p 5666 bxn818204@www.woaixiaoyu.xyz
```

### 2. 在服务器上执行以下命令

```bash
#!/bin/bash

# 创建应用目录
mkdir -p ~/miniyum-lark
cd ~/miniyum-lark

# 克隆或更新代码
if [ -d ".git" ]; then
    git pull origin master
else
    git clone https://github.com/bxn818204/miniyum-Lark.git .
fi

# 创建 .env 配置文件
cat > .env << 'EOF'
FEISHU_APP_ID=cli_a911153c86789ed0
FEISHU_APP_SECRET=8OUmPXW0dL2xEjSEbNu5iduwLuQGxNdA
DEEPSEEK_API_KEY=sk-48a337fe74bb4aa989ca369171598e69
PORT=3001
CLAUDE_API_KEY=sk-qB2fhoAQqIfFx2I2Gplcw0wo9w9l6nzwOpTRaEhRG0ua1NU4
EOF

# 打开防火墙（如果需要）
sudo ufw allow 3001/tcp 2>/dev/null || true

# 停止旧容器
docker-compose down 2>/dev/null || true

# 启动新服务
docker-compose up -d --build

# 查看日志
docker-compose logs --tail 30 -f
```

## 方法二：使用 SCP 上传部署脚本

### 1. 本地机器上执行
```bash
# 将部署脚本上传到服务器
scp -P 5666 deploy-to-server.sh bxn818204@www.woaixiaoyu.com:~/

# SSH 登录并执行
ssh -p 5666 bxn818204@www.woaixiaoyu.com "chmod +x ~/deploy-to-server.sh && ~/deploy-to-server.sh"
```

## 方法三：使用 GitHub Actions 自动部署

可以在仓库中配置 `.github/workflows/deploy.yml` 以自动部署

## 验证部署

### 查看服务状态
```bash
docker ps | grep miniyum
```

### 查看日志
```bash
docker-compose logs -f
```

### 停止服务
```bash
docker-compose down
```

### 测试 API
```bash
curl http://localhost:3001
```

## 常见问题

### 1. Docker 未安装
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### 2. docker-compose 版本过低
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 3. 权限问题
```bash
sudo usermod -aG docker $USER
# 注销并重新登录以应用更改
```

### 4. 端口已占用
```bash
# 查看占用 3001 端口的进程
sudo lsof -i :3001
sudo fuser -k 3001/tcp
```

## 部署完成后

- 应用将在 `http://服务器IP:3001` 上运行
- 更新代码后，只需在服务器上运行：
  ```bash
  cd ~/miniyum-lark
  git pull origin master
  docker-compose up -d --build
  ```
