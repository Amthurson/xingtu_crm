#!/bin/bash
# 部署到宿主服务器nginx

echo "=========================================="
echo "    部署到宿主服务器Nginx"
echo "=========================================="
echo ""

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用root用户运行此脚本"
    exit 1
fi

# 检查nginx是否安装
if ! command -v nginx &> /dev/null; then
    echo "正在安装Nginx..."
    if command -v yum &> /dev/null; then
        yum install -y nginx
    elif command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y nginx
    else
        echo "错误: 无法自动安装nginx，请手动安装"
        exit 1
    fi
fi

# 创建前端目录
FRONTEND_DIR="/usr/local/apps/xingtu_crm/frontend/dist"
echo "创建前端目录: $FRONTEND_DIR"
mkdir -p $FRONTEND_DIR

# 检查dist目录是否存在（支持多个可能的位置）
if [ ! -d "./frontend/dist" ] && [ ! -d "/usr/local/apps/xingtu_crm/frontend/dist" ]; then
    echo "错误: frontend/dist 目录不存在"
    echo "请先构建前端或上传dist目录"
    exit 1
fi

# 如果当前目录有dist，使用当前目录；否则使用绝对路径
if [ -d "./frontend/dist" ]; then
    DIST_SOURCE="./frontend/dist"
else
    DIST_SOURCE="/usr/local/apps/xingtu_crm/frontend/dist"
fi

# 复制前端文件
echo "复制前端文件..."
if [ -d "./frontend/dist" ]; then
    cp -r ./frontend/dist/* $FRONTEND_DIR/
else
    echo "使用已存在的dist目录: $FRONTEND_DIR"
fi
echo "✓ 前端文件位置: $FRONTEND_DIR"

# 配置nginx
NGINX_CONF="/etc/nginx/conf.d/xingtu_crm.conf"
echo ""
echo "配置Nginx..."

# 备份原配置（如果存在）
if [ -f "$NGINX_CONF" ]; then
    cp $NGINX_CONF ${NGINX_CONF}.bak
    echo "已备份原配置: ${NGINX_CONF}.bak"
fi

# 复制nginx配置
cp nginx-host.conf $NGINX_CONF
echo "✓ Nginx配置已复制到 $NGINX_CONF"

# 测试nginx配置
echo ""
echo "测试Nginx配置..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✓ Nginx配置测试通过"
    
    # 重载nginx
    echo ""
    echo "重载Nginx..."
    systemctl reload nginx || nginx -s reload
    
    if [ $? -eq 0 ]; then
        echo "✓ Nginx已重载"
    else
        echo "⚠ Nginx重载失败，请手动检查"
    fi
else
    echo "✗ Nginx配置有错误，请检查"
    exit 1
fi

# 获取服务器IP
SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo "          部署完成！"
echo "=========================================="
echo "前端访问: http://${SERVER_IP}"
echo "API文档:  http://${SERVER_IP}/docs"
echo ""
echo "确保后端服务正在运行:"
echo "  docker-compose ps"
echo "  或"
echo "  docker-compose up -d backend"
echo ""
echo "Nginx配置位置: $NGINX_CONF"
echo "前端文件位置: $FRONTEND_DIR"
echo "=========================================="
