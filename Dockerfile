# syntax=docker/dockerfile:1.4
FROM node:20-alpine AS builder
WORKDIR /app

# 安装系统依赖
RUN apk add --no-cache python3 make g++

# 复制依赖文件并安装（启用缓存）
COPY ./web/package*.json ./web/
RUN --mount=type=cache,target=/app/web/node_modules \
    --mount=type=cache,target=/root/.npm \
    cd ./web && npm config set registry https://registry.npmjs.org/ && \
    npm i --prefer-offline --no-audit --legacy-peer-deps

# 复制代码并构建
COPY . .
RUN --mount=type=cache,target=/app/web/node_modules \
    cd ./web && npm run build

# 生产镜像
FROM nginx:alpine
COPY --from=builder /app/web/dist /usr/share/nginx/html
COPY deploy/web.conf /etc/nginx/conf.d/web.conf

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

ENV LANG=zh_CN.UTF-8
EXPOSE 80
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]
