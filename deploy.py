#!/usr/bin/env python3
"""
SSH 部署脚本 - 直接在远程服务器部署 miniyum-lark
"""

import paramiko
import time
import sys

def deploy_to_server():
    # 服务器信息
    hostname = "www.woaixiaoyu.xyz"
    port = 22
    username = "bxn818204"
    password = "Aaa@13278505045"
    
    # 部署脚本
    deploy_script = """
#!/bin/bash
set -e

cd ~/miniyum-lark

echo "========== 部署验证开始 =========="
echo ""

# 1. 检查代码
echo "[1/5] 检查代码..."
ls -lh | head -5
echo ""

# 2. 验证配置
echo "[2/5] 验证 .env 文件..."
if [ -f .env ]; then
    echo "✓ .env 文件存在"
    cat .env
else
    echo "✗ .env 文件不存在"
    exit 1
fi
echo ""

# 3. 验证 Docker
echo "[3/5] 检查 Docker..."
docker --version || echo "⚠ Docker 命令失败"
docker-compose --version || echo "⚠ docker-compose 命令失败"
echo ""

# 4. 启动服务
echo "[4/5] 启动服务..."
docker-compose down 2>/dev/null || true
docker-compose up -d --build 2>&1 | tail -5
echo ""

# 5. 验证启动
echo "[5/5] 验证服务状态..."
sleep 3
docker-compose ps
echo ""
docker-compose logs --tail 15
echo ""
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "========== 部署完成 =========="
echo ""
echo "✅ 应用已启动！"
echo "本地访问: http://localhost:3001"
echo "远程访问: http://$SERVER_IP:3001"
echo ""
"""
    
    try:
        print("[*] 连接到服务器...")
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(hostname, port=port, username=username, password=password, timeout=10)
        
        print(f"[✓] 已连接到 {hostname}")
        print(f"[*] 执行部署脚本...\n")
        
        # 执行脚本
        stdin, stdout, stderr = client.exec_command(f"bash -s << 'DEPLOY_EOF'\n{deploy_script}\nDEPLOY_EOF")
        
        # 实时输出
        for line in stdout:
            print(line.rstrip())
        
        # 检查错误
        for line in stderr:
            print(f"[ERROR] {line.rstrip()}")
        
        exit_status = stdout.channel.recv_exit_status()
        
        if exit_status == 0:
            print("\n[✓] 部署成功！")
        else:
            print(f"\n[✗] 部署失败，exit code: {exit_status}")
        
        client.close()
        return exit_status == 0
        
    except Exception as e:
        print(f"[✗] 错误: {e}")
        return False

if __name__ == "__main__":
    success = deploy_to_server()
    sys.exit(0 if success else 1)
