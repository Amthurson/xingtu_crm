#!/bin/bash
# 在服务器上导入镜像

echo "=========================================="
echo "    导入Docker镜像"
echo "=========================================="
echo ""

# 检查tar文件是否存在
TAR_DIR="/tmp"
if [ -n "$1" ]; then
    TAR_DIR="$1"
fi

cd $TAR_DIR

# 导入镜像
for tar_file in postgres_15-alpine.tar python_3.11-slim.tar node_18-alpine.tar nginx_alpine.tar; do
    if [ -f "$tar_file" ]; then
        echo "导入 $tar_file ..."
        docker load < "$tar_file"
        if [ $? -eq 0 ]; then
            echo "✓ 成功"
        else
            echo "✗ 失败"
        fi
    else
        echo "⚠ 未找到 $tar_file"
    fi
done

echo ""
echo "=========================================="
echo "    导入完成"
echo "=========================================="
echo ""
echo "验证镜像："
docker images | grep -E "python|node|postgres|nginx"

echo ""
echo "现在可以运行: docker-compose up -d"
