# API 网关系列--Kong 介绍、安装、使用
kong 是基于 openresty 与 nginx 的一款 API 网关，有开源和付费两个版本，这里只针对开源版.

## 主要名词与使用
* Service: 服务是一个具体的后端服务实体或者是一个 API，最主要的就是 URL：后端服务的地址，所有匹配到该服务的请求都会被代理到 URL 上，与之相搭配的还有 protocol, host,port 以及 path
* Route: 路由定义了一个请求是否以及如何被代理到服务上，一个 Service 可以有多个 Route.
* Plugin: 插件，提供网关其他功能，例如：跨域、鉴权、限流等等，插件既可以作用于 Service 也可以作用于 Route，还可以作用于全局。
## 部署架构
kong 部署架构目前提供了三种模式，db 的有两种，db-less 一种。
### db 部署方式
推荐使用 postgresql
### db-less 部署方式
使用 yaml 配置文件，每次修改都需要修改 yaml 文件并导入。
优点：不依赖 db
缺点：需要维护各个节点的 yaml 文件,并且目前只支持一个 yaml 文件，当接入服务越来越大，yaml 文件也会变得难以维护。
## 安装
### 安装方式
官方 2.0 版本之前都是采用的 db 方式:即将配置存储到 某一 db 中，官方支持的是 cassandra 和 postgres, 2.0 开始支持 db-less，以及为了防止集群过大与数据库连接过多，采用分离的部署方式：数据平面和控制平面。
我这里使用 db 方式，db 采用 postgresql 安装方式官网提供了不同方式，这里我选择用 docker 的方式。(假设你已经有了 [docker](https://docs.docker.com/get-docker/) 和 [postgresql](https://hub.docker.com/_/postgres)，公司内部都会有专门的 DBA 来维护。如果没有请点击链接)。
* 安装
安装很简单，利用 docker 方式可以说是一键拉起了：这里提供个简单的脚本
```
# start.sh
#!/usr/bin/env bash
if [ $# != 2 ]; then
    echo "miss image version or command"
    exit 1
fi

version=$1
image=kong:${version}

mup() {
    sudo docker run --rm \
        -e "KONG_CLIENT_MAX_BODY_SIZE=32m" \
        -e "KONG_PG_HOST=${KONG_PG_HOST}" \
        -e "KONG_PG_PORT=${KONG_PG_PORT}" \
        -e "KONG_PG_USER=${KONG_PG_USER}" \
        -e "KONG_PG_PASSWORD=${KONG_PG_PWD}" \
        -e "KONG_PG_DATABASE=${KONG_PG_DB}" \
        -e "KONG_NGINX_WORKER_PROCESSES=${KONG_PROCESS_NUM}" \
        -e "KONG_LOG_LEVEL=${KONG_LOG_LEVEL}" \
        ${image} kong migrations up
}

start(){
    sudo docker run -d --restart=always --name ${name} --net=kong-net \
        --log-driver json-file --log-opt max-size=512m --log-opt max-file=5 \
        --cpus=3 --cpuset-cpus="0-2" --memory="2g" --cpuset-mems="0" \
        -p 8001:8000 -p 9081:9080 \
        -e "KONG_CLIENT_MAX_BODY_SIZE=32m" \
        -e "KONG_PG_HOST=${kong_pg_host}" \
        -e "KONG_PG_PORT=${kong_pg_port}" \
        -e "KONG_PG_USER=${kong_pg_user}" \
        -e "KONG_PG_PASSWORD=${kong_pg_pwd}" \
        -e "KONG_PG_DATABASE=${kong_pg_db}" \
        -e "KONG_NGINX_WORKER_PROCESSES=${KONG_PROCESS_NUM}" \
        -e "KONG_LOG_LEVEL=warn" \
        -e "KONG_MEM_CACHE_SIZE=1024m" \
        -e "KONG_ANONYMOUS_REPORTS=false" \
        -e "KONG_PROXY_LISTEN=0.0.0.0:8000 reuseport backlog=16384, 0.0.0.0:8443 http2 ssl reuseport backlog=16384" \
        ${image} start
}
func=$2
$func
```
* 管理界面-konga
## konga 使用