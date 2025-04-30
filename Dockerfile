FROM node:20-alpine AS builder
WORKDIR /app

COPY . .
RUN apk add --no-cache xdg-utils
RUN cd ./web && npm i  && npm run build

FROM nginx:alpine

COPY --from=builder /app/web/dist /usr/share/nginx/html
COPY deploy/web.conf /etc/nginx/conf.d/web.conf

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

ENV LANG=zh_CN.UTF-8
EXPOSE 80
ENTRYPOINT [ "nginx", "-g", "daemon off;" ]