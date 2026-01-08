FROM node:24.3.0-alpine as build

WORKDIR /app

# 安装pnpm
RUN npm install -g pnpm@latest

# 配置pnpm镜像源（使用国内镜像）
RUN pnpm config set registry https://registry.npmmirror.com

# 复制package文件
COPY package*.json ./
COPY pnpm-lock.yaml* ./

# 安装依赖（pnpm比npm更节省内存和磁盘空间）
RUN pnpm install --frozen-lockfile || pnpm install

# 复制源代码
COPY . .

# 构建应用（pnpm构建时内存占用更少）
RUN pnpm run build

# 生产环境镜像
FROM nginx:alpine

# 复制构建产物
COPY --from=build /app/dist /usr/share/nginx/html

# 复制nginx配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
