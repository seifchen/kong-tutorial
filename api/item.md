# 各名词详解
本节将详解各个名词之间的配置，包括 service、route、plugins、consumer 等。

## Service
* name: 服务名称，自己配置，能够“见名知义”就好，可以是部门名称-服务名
* protocol: 与上游服务通信使用的协议，目前支持 "grpc", "grpcs", "http", "https", "tcp", "tls". 默认值: "http"
* host: 上游服务器的地址, http://www.baidu.com 对应于 www.baidu.com
* port: 上游服务器的服务端口号, 默认为 80
* path: 这个 path 和 routes 的 paths 不同，这是代理到上游服务时指定的路径，默认为 '/', 比如这里填写为 /api，那么所有路由到此 service 上的请求在代理到上游时都会加上 /api,比如 route path 配置为 /test, 那么当你请求 http://\$KONG_URL/test/get 时实际请求到上游服务的地址是 http://\$UPSTREAM_URL/api/get
* retries: 代理失败后，kong 会自动重试，重试次数就由此字段设定，默认为 5。
* connect_timeout: 与上游建立连接的超时时间。单位 ms, 默认为 60s,假如在 kong 之前还配置了 nginx 等负载均衡器，那么此值应该要比负载均衡器的略低。
* write_timeout: 在将请求传输到上游服务器两个连续写操作之间超时时间，默认值 60s。
* read_timeout: 两个连续读请求操作之间的超时时间。
* tags: 标签，用于分类此服务的类别，比如可以添加部门名称作为分类，这样在获取同个部门下有多少服务时，传递此 tag 即可。

## Route
route(路由):是具体的匹配规则，上面的服务只是当匹配到某一个

## Plugins

## Consumer