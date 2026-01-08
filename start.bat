@echo off
chcp 65001 >nul
echo ==========================================
echo       达人老师CRM系统 - 一键启动脚本
echo ==========================================
echo.

REM 检查Docker是否安装
where docker >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到Docker，请先安装Docker
    pause
    exit /b 1
)

REM 检查Docker Compose是否安装
where docker-compose >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未检测到Docker Compose，请先安装Docker Compose
    pause
    exit /b 1
)

echo ✓ Docker环境检查通过
echo.

REM 检查Docker镜像加速器配置
echo 检查Docker镜像加速器配置...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo 警告: 无法连接到Docker，可能需要配置镜像加速器
    echo 请参考 NETWORK_SETUP.md 进行配置
    echo 或运行: .\setup-docker-mirror.ps1
    echo.
    pause
    exit /b 1
)

REM 启动服务
echo 正在启动服务...
docker-compose up -d

echo.
echo 等待服务启动...
timeout /t 5 /nobreak >nul

REM 检查服务状态
echo.
echo ==========================================
echo           服务状态
echo ==========================================
docker-compose ps

echo.
echo ==========================================
echo           访问地址
echo ==========================================
echo 前端界面: http://localhost:8080
echo 后端API:  http://localhost:8000
echo API文档:  http://localhost:8000/docs
echo.
echo 查看日志: docker-compose logs -f
echo 停止服务: docker-compose down
echo ==========================================
pause


