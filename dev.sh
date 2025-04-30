#!/bin/bash
cd "$(cd "$(dirname "$0")" && pwd)"
project_name=$(basename "$(pwd)")

vf_port=${vf_port:-9090}
version=${vf_version:-latest}
images=breakthroughapi-web:latest

# 打印带时间前缀的消息
print_message() {
    local level=$1
    local message=$2
    local color_code=''
    local reset_color='\033[0m'

    case $level in
        INFO|info)
            color_code='\033[32m'  # 绿色
            ;;
        WARN|warn)
            color_code='\033[33m'  # 黄色
            ;;
        ERROR|error)
            color_code='\033[31m'  # 红色
            ;;
        *)
            color_code='\033[0m'   # 默认色
            ;;
    esac

    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${color_code}${message}${reset_color}"
}
# 更新镜像
update_images() {
    print_message INFO "正在拉取镜像..."
    docker pull ${image}
    print_message INFO "镜像拉取完成"
}

# 查看日志
show_logs() {
    count=${1:-100}
    docker logs -f --tail $count "${project_name}"
}


# 不存在容器
is_not_exist() {
    if ! docker ps -a | grep -wq "${project_name}"; then
        print_message WARN "未找到开发容器：${project_name}，请先运行 $0 start 命令启动" >&2
        exit 1
    fi
}

# 存在容器
is_exist() {
    if docker ps -a | grep -wq "${project_name}"; then
        print_message WARN "检测到已存在容器：${project_name}，你可以执行 $0 reset | update 重建或更新容器" >&2
        exit 1
    fi
}

# 查看容器
show() {
    is_not_exist
    if [[ -z $1 ]];then
        docker ps -a | grep -w "${project_name}"
    else
        docker inspect "${project_name}"
    fi
}

# 登录容器
login() {
    is_not_exist
    docker exec -ti "${project_name}" ${1:-bash}  -c "echo -e '\033[32m已成功进入容器，现在你可以执行命令操作了...\033[0m';echo ; ${1:-bash}"
}

# 构建镜像
build() {
    print_message INFO "正在构建开发镜像..."
    docker build --no-cache --network host . -t $images
    print_message INFO "镜像构建完成"
}
# 删除镜像
delete_img() {
    print_message INFO "正在删除开发镜像..."
    docker rim $image 
    print_message INFO "镜像删除完成"
}

# 启动开发容器
start() {
    print_message INFO "正在启动开发容器..."
    docker run -dti \
        --name="${project_name}" \
        --restart=always \
        -p 80:80 \
        breakthroughapi-web:latest
    show_logs "${project_name}"
}

# 重启开发容器
restart() {
    is_not_exist
    print_message WARN "正在重启开发容器..."
    docker restart "${project_name}"
    print_message INFO "容器重启成功！"
}

# 销毁开发容器
destroy() {
    print_message WARN "即将销毁开发容器：${project_name}..."
    docker rm -f "${project_name}"
    print_message WARN "容器销毁成功！"
}

# 重建开发容器
reset() {
    build
    start
}

# 打印帮助信息
print_help() {
    echo
    echo "欢迎使用 FastFlyer 开发环境辅助工具。"
    echo
    echo "用法: $0 <OPTION>"
    echo "命令:"
    echo "     start        启动开发容器"
    echo "     show [D]     查看开发容器"
    echo "     login        进入开发容器"
    echo "     update       更新容器插件"
    echo "     restart      重启开发容器"
    echo "     reset        重建开发容器"
    echo "     destroy      销毁开发容器"
    echo "     log [COUNT]  查看容器日志"
    echo
}

# 处理命令
case "$1" in
    "build")
        build
        ;;
    "start")
        start
        ;;
    "show")
        show $2
        ;;
    "login")
        login
        ;;
    "restart")
        restart
        ;;
    "destroy")
        destroy
        ;;
    "reset")
        reset
        ;;
    "logs"|"log")
        show_logs $2
        ;;
    *)
        print_help
        ;;
esac

