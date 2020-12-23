# CORS
本节将介绍 web 领域中一个非常重要的插件：CORS（跨域）插件，在介绍此插件之前会简单介绍下跨域的基本理论。

## 跨域相关概念
何为跨域？为什么会有跨域？什么时候会出现跨域？如果你能轻松的回答出这三个问题，那么可以直接跳到 [cors 插件使用](#cors-插件使用),否则可以继续往下读
### 何为跨域？
再讲解何为跨域之前，我先说下几个概念：
* 首先明确一点：跨域只会出现在 web|h5 端，也就是说，在原生的 ios 以及 android 等不存在这一问题的。当然在手机端访问 web|h5 还是会有跨域，这点别搞混了！
* 其次再明确一点：跨域行为是浏览器表现出来的。
* 第三：跨域的域指的是域名，请求协议，端口等等，但我们最多使用的就是前后端的域名。
* 第四：跨域是 HTTP 协议里的。
明确以上几点我们再来说何为跨域
cors(cross-origin resources sharing) 即跨域资源共享，是一种机制，它使用额外的 HTTP 标头来告诉浏览器，让运行在一个 origin 下的 web 应用被准许访问另一个不在一个同源下的服务器上的指定资源。当一个 web 应用请求一个和它不在一个域（域名，请求协议，端口）下的资源时就会发起跨域请求。打个比方：
从一个 http://domain-A.com 的前端的 js 代码中，去请求一个
http://domain-B.com/request 时就会发生跨域请求。好了我们
知道什么是跨域了，那么为什么会有跨域或者说为什么会出现跨域呢？
### 为什么会有跨域？
其实上面刚刚说了跨域是浏览器的行为，是由于浏览器的同源策略导致跨域产生的，那么浏览器为啥会搞个同源策略呢，其实浏览器是为了我们的安全着想，这还是一个安全问题。这里太过复杂不做过多讨论，举个简单例子 CSRF 攻击：
相信大家对于 cookie 都比较熟悉了，这里面放着我们登陆某个网站的用户名密码等信息，当年你第一次登陆比如淘宝时，服务器验证你的信息之后就会，就会在响应头里加上 Set-Cookie 这个字段，浏览器再发送请求时就会自动将 cookie 放在请求头 Cookie 这个字段之中，服务端通过这个 cookie 字段就能判断用户是否登录，是否有效，是谁了。
你先在淘宝上登录了正逛得起兴呢，收到了封邮件，里面有个链接: www.noway.com，你正看着这个网站呢，但是这个网站向淘宝发送了个请求，淘宝收到了这个请求，校验了 cookie 成功，就执行了这个请求，攻击就完成了，在你不知道的情况下就完成了操作，试想下如果是银行呢？那你的钱就损失了。而有了跨域这一机制，cookie 就不会自动携带过去，但是同样可以获取到，但是还有个 httpOnly 机制可以避免前端 js 脚本操纵 cookie，不做过多详解。

### 什么时候会出现跨域
首先要明确一点，浏览器发现有跨域的时候，会先发送一个 OPTIONS（预检请求) 请求来判断是否允许跨域，允许跨域了才会真正发送请求，否则就不会。
简单请求不会触发预检请求，何为简单？并不是只有 GET 为简单，有些情况下 POST 请求也可以是简单请求，主要有以下条件:
1. 请求的 Method 是以下几种之一:
    * GET
    * POST
    * HEAD
2. 除了由用户代理自动设置的标头（例如，Connection，User-Agent或Fetch规范中定义为“禁止标头名称”的其他标头）之外，请求的标头在以下之列
    * Accept
    * Accept-Language
    * Content-Language
    * Content-Type (这个字段的值有限制)
    * DPR
    * Downlink
    * Save-Data
    * Viewport-Width
    * Width
3. Content-Type 必须是以下几种:
    * application/x-www-form-urlencoded
    * multipart/form-data
    * text/plain
4. 没有在请求中使用的任何XMLHttpRequestUpload对象上注册事件侦听器；这些可以使用XMLHttpRequest.upload属性进行访问。
5. 请求中未使用ReadableStream对象。

不是简单请求就会触发跨域。知道了何时会出现跨域，那么有时候我们确实会想让某些我们确认安全的请求通过跨域该如何做呢，下面就着重讲下在 kong 上如何利用 cors 插件来达到上面说的效果。当然一些知识点是通用的，比如 Header 里的各种信息。

## cors 插件使用

先讲下 cors 插件的 config 各个参数的含义:
* origins: 即允许哪些 origin 可以请求这个服务或者接口，注意这个是前端的域名(http://example.com:port), 如果插件发现请求的 Origin 字段的值在这个列表里，就会在响应头Access-Control-Allow-Origin 加上这个 origin。支持 http://.*example.com:.* 正则形式。
* headers: 允许哪些请求头可以发送真实请求，如果请求的 header 在列表里会在响应字段：Access-Control-Allow-Headers 设置上。
* exposed_headers: 设置后端服务响应的请求头中哪些可以暴露给浏览器，通过在响应头: Access-Control-Expose-Headers 设置。
* methods: 指定访问资源时允许使用的一种或多种方法。同样当请求的 Method 在所配置的列表里时会在响应头: Access-Control-Allow-Methods 加上这个 method。默认为:
["GET","HEAD","PUT","PATCH","POST","DELETE","OPTIONS","TRACE","CONNECT"]
* max_age: 对应 Access-Control-Max-Age，设置预检请求的结果可以缓存多久。
* credentials: 对应 Access-Control-Allow-Credentials，指示是否允许浏览器发送 cookie 给服务器。一般都设为 true.
* preflight_continue: 是否将 OPTIONS 请求继续传递，默认为 false。
  

一般安全要求不高的只需要设置 origins 限制访问的 oigin 即可。
下面我们直接在 konga 上建立个服务。路由为 /test, 先不开启插件
后端服务就用 kong 的 8000 端口
我们就用 curl 来模拟下跨域请求,先发送下列请求: 响应头并没有
Access-Control-Allow-Origin
```
curl -XOPTIONS  http://localhost:8000/test -v -H 'origin:http://www.example.com'
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8000 (#0)
> OPTIONS /test HTTP/1.1
> Host: localhost:8000
> User-Agent: curl/7.64.1
> Accept: */*
> origin:http://www.example.com
>
< HTTP/1.1 404 Not Found
< Content-Type: application/json; charset=utf-8
< Content-Length: 48
< Connection: keep-alive
< Date: Sun, 13 Sep 2020 10:13:04 GMT
< X-Kong-Response-Latency: 0
< Server: kong/2.0.1
< X-Kong-Upstream-Latency: 1
< X-Kong-Proxy-Latency: 3
< Via: kong/2.0.1
<
* Connection #0 to host localhost left intact
{"message":"no Route matched with those values"}* Closing connection 0
```
开启 cors 插件，orgins 填写 'http://www.example.com'。再请求,响应头里已经有相关的 Access-Control-Allow-Origin 了：
```
curl -XOPTIONS  http://localhost:8000/test -v -H 'origin:http://www.example.com'
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8000 (#0)
> OPTIONS /test HTTP/1.1
> Host: localhost:8000
> User-Agent: curl/7.64.1
> Accept: */*
> origin:http://www.example.com
>
< HTTP/1.1 404 Not Found
< Content-Type: application/json; charset=utf-8
< Content-Length: 48
< Connection: keep-alive
< Date: Sun, 13 Sep 2020 10:11:56 GMT
< X-Kong-Response-Latency: 0
< Server: kong/2.0.1
< Vary: Origin
< Access-Control-Allow-Origin: http://www.example.com
< X-Kong-Upstream-Latency: 1
< X-Kong-Proxy-Latency: 0
< Via: kong/2.0.1
<
* Connection #0 to host localhost left intact
{"message":"no Route matched with those values"}* Closing connection 0
```

修改插件配置，methods 为 ["GET"],再请求，会发现多了个 Access-Control-Allow-Methods，当 Access-Control-Request-Method的 methods 与响应头无法对齐时，浏览器就判断不允许发送跨域请求:
```
 curl -XOPTIONS  http://localhost:8000/test -v -H 'origin:http://www.example.com'  -H 'Access-Control-Request-Method:["POST"]'
*   Trying ::1...
* TCP_NODELAY set
* Connected to localhost (::1) port 8000 (#0)
> OPTIONS /test HTTP/1.1
> Host: localhost:8000
> User-Agent: curl/7.64.1
> Accept: */*
> origin:http://www.example.com
> Access-Control-Request-Method:["POST"]
>
< HTTP/1.1 200 OK
< Date: Sun, 13 Sep 2020 10:17:39 GMT
< Connection: keep-alive
< Vary: Origin
< Access-Control-Allow-Origin: http://www.example.com
< Access-Control-Allow-Methods: GET # 允许的方法。
< Content-Length: 0
< X-Kong-Response-Latency: 1
< Server: kong/2.0.1
<
* Connection #0 to host localhost left intact
* Closing connection 0
```


## 接下来
你可以继续查看 [kong 插件使用-allow-path-list](allow-path-list.md)
