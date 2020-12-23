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
* name: 路由名称，同样做到见名知义。
* protocols: 请求协议，指的是请求 kong 网关时的请求协议，默认为 ["http","https"]。
* methods: 此路由匹配的请求方法，可选的有["GET","PUT","POST","OPTIONS","HEAD","DELETE","PATCH","CONNECT","TRACE"]
* hosts: 匹配此路由的 host,注意这个是绑定到你 kong 网关的域名而不是后端服务的域名，比如你网关绑定了两个域名 host1,host2,而在 route 上只配置了 host1 时，那么只有用 host1 请求网关才能正确路由，用 host2 只会得到 404 错误。
* paths: 匹配此路由的 path 列表。
* headers: 匹配此路由的 headers 列表。注意 HOST 已经用 hosts 字段指定了，不能在此字段指定。
* regex_priority: 指定路由匹配的优先级，当两个路由都匹配到了时，并且优先级也相同，那么会使用 created_at 最旧的。默认值为 0 。
* strip_path: 代理到后端路径时，是否将 route 的 path 给剔除，默认值为 true。比如 path 为 /test，如果选择 false, 那么当请求 /test/get 代理到后端路径时为 http://\$UPSTREAM_URL/test/get, 为 true 则代理到 http://\$UPSTREAM_URL/get
* preserve_host: 是否将 匹配的 hosts 列表中的 host 代理到 后端去，体现在请求的 HOST 字段。
* tags: 标签，和 service 用法一致。 

## Plugins
* name: 插件名称
* route: 作用的路由
* service： 作用的服务
* consumer: 作用的 consumer
* config: pugins 配置各不相同，根据插件 config 配置。
* protocols: 与 route protocls 一致
* enabled: 是否开启
* tags: 与 service、route tags 含义一致

## Consumer
消费 API 的消费者, 一个服务与路由利用 ACL 可以限制哪些 consumer 可以消费。后面讲到插件会介绍。
* username: 消费者的用户名，必须全局唯一。
* custom_id: 用户存储的唯一id, 用来和现有数据库中的用户一一映射。
* tags: 与 service、route tags 含义一致。


## 接下来
你可以继续查看 [kong 网关介绍、安装、使用](kong.md)