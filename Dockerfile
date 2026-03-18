# 使用镜像代理地址，绕过直接访问 Docker Hub 的限制
FROM m.daocloud.io/docker.io/library/nginx:alpine

# 使用轻量级 Nginx 镜像
# FROM nginx:alpine

# 复制 dist 目录下的文件到 Nginx 默认静态资源目录
COPY dist/ /usr/share/nginx/html/

# 复制自定义 Nginx 配置（解决路由刷新 404）
# 如果你现在没有 nginx.conf，可以先跳过这一步，
# 但如果要用 Vue Router 的 History 模式，后续必须加上。
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# docker run -d \
#   -p 80:80 \
#   --name my-web-site \
#   --restart always \
#   -v /root/logs:/var/log/nginx \
#   crpi-ff663sc2kczslcpj.cn-hangzhou.personal.cr.aliyuncs.com/loremipsum233/vite-demo:v1.0