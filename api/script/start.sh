# start.sh
#!/usr/bin/env bash
if [ $# != 2 ]; then
    echo "miss image version or command"
    exit 1
fi

version=$1
image=kong:${version}-centos

args1='-e "KONG_CLIENT_MAX_BODY_SIZE=32m"
        -e "KONG_PG_HOST=${KONG_PG_HOST}" 
        -e "KONG_PG_PORT=${KONG_PG_PORT}" 
        -e "KONG_PG_USER=${KONG_PG_USER}" 
        -e "KONG_PG_PASSWORD=${KONG_PG_PWD}" 
        -e "KONG_PG_DATABASE=${KONG_PG_DB}" 
        -e "KONG_NGINX_WORKER_PROCESSES=${KONG_PROCESS_NUM}" 
        -e "KONG_LOG_LEVEL=${KONG_LOG_LEVEL}"'

mup() {
    docker run --rm --net=kong-net \
        ${args1} \ 
        ${image} kong migrations up
}

mdone() {
    docker run --rm --net=kong-net \
        $args1 \
        ${image} kong migrations done
}

init() {
    docker run --rm --net=kong-net \
	-e "KONG_CLIENT_MAX_BODY_SIZE=32m" \
        -e "KONG_PG_HOST=${KONG_PG_HOST}" \
        -e "KONG_PG_PORT=${KONG_PG_PORT}" \
        -e "KONG_PG_USER=${KONG_PG_USER}" \
        -e "KONG_PG_PASSWORD=${KONG_PG_PWD}" \
	-e "KONG_PG_DATABASE=${KONG_PG_DB}" \
	-e "KONG_NGINX_WORKER_PROCESSES=${KONG_PROCESS_NUM}" \
        -e "KONG_LOG_LEVEL=${KONG_LOG_LEVEL}" \
        ${image} kong migrations bootstrap
}


name=kong
start(){
    docker run -d --restart=always --name ${name} --net=kong-net \
	--log-driver json-file --log-opt max-size=512m --log-opt max-file=5 \
	--cpus=1 --cpuset-cpus="0" --memory="2g" --cpuset-mems="0" \
	-p 8000:8000 -p 9081:9080 \
	-e "KONG_CLIENT_MAX_BODY_SIZE=32m" \
        -e "KONG_PG_HOST=${KONG_PG_HOST}" \
        -e "KONG_PG_PORT=${KONG_PG_PORT}" \
        -e "KONG_PG_USER=${KONG_PG_USER}" \
        -e "KONG_PG_PASSWORD=${KONG_PG_PWD}" \
        -e "KONG_PG_DATABASE=${KONG_PG_DB}" \
        -e "KONG_NGINX_WORKER_PROCESSES=${KONG_PROCESS_NUM}" \
        -e "KONG_LOG_LEVEL=warn" \
        -e "KONG_MEM_CACHE_SIZE=1024m" \
        -e "KONG_ANONYMOUS_REPORTS=false" \
        -e "KONG_ADMIN_LISTEN=0.0.0.0:8001" \
        -e "KONG_PROXY_LISTEN=0.0.0.0:8000 reuseport backlog=16384, 0.0.0.0:8443 http2 ssl reuseport backlog=16384" \
        ${image}
}
func=$2
$func
