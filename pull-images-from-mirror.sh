#!/bin/bash
# 从国内镜像源手动拉取镜像并重命名

echo "=========================================="
echo "    从国内镜像源拉取基础镜像"
echo "=========================================="
echo ""

# 方法1：尝试从镜像加速器拉取（如果配置正确）
echo "方法1: 尝试从镜像加速器拉取..."
docker pull python:3.11-slim 2>&1 | tail -3
docker pull node:18-alpine 2>&1 | tail -3
docker pull postgres:15-alpine 2>&1 | tail -3
docker pull nginx:alpine 2>&1 | tail -3

# 如果方法1失败，使用方法2：从阿里云镜像仓库拉取
echo ""
echo "如果方法1失败，尝试方法2: 从阿里云镜像仓库拉取..."

# 注意：需要找到对应的阿里云镜像地址
# 这里提供一些常见的镜像源

echo ""
echo "如果以上都失败，可以："
echo "1. 检查网络连接"
echo "2. 尝试使用VPN或代理"
echo "3. 使用docker-compose build时，镜像会在构建时自动拉取（如果镜像加速器配置正确）"
