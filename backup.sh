#!/bin/bash
# 数据库备份脚本

BACKUP_DIR="/opt/backups/xingtu_crm"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份数据库
echo "开始备份数据库..."
docker-compose exec -T postgres pg_dump -U postgres xingtu_crm > $BACKUP_DIR/db_$DATE.sql

if [ $? -eq 0 ]; then
    echo "✓ 备份成功: $BACKUP_DIR/db_$DATE.sql"
    
    # 压缩备份文件
    gzip $BACKUP_DIR/db_$DATE.sql
    echo "✓ 备份文件已压缩"
    
    # 删除旧备份（保留最近7天）
    find $BACKUP_DIR -name "db_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    echo "✓ 已清理$RETENTION_DAYS天前的备份"
else
    echo "✗ 备份失败"
    exit 1
fi
