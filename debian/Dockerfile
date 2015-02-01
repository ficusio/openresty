FROM debian:wheezy

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl perl make build-essential procps \
    libreadline-dev libncurses5-dev libpcre3-dev libssl-dev \
 && rm -rf /var/lib/apt/lists/*

ENV OPENRESTY_VERSION 1.7.7.1

RUN cd /root \
 && echo "==> Downloading OpenResty..." \
 && curl -sSL http://openresty.org/download/ngx_openresty-${OPENRESTY_VERSION}.tar.gz | tar -xvz \
 && echo "==> Configuring OpenResty..." \
 && cd ngx_openresty-* \
 && readonly NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
 && echo "using upto $NPROC threads" \
 && ./configure \
    --prefix=/opt/openresty \
    --http-client-body-temp-path=/var/nginx/client_body_temp \
    --http-proxy-temp-path=/var/nginx/proxy_temp \
    --http-log-path=/var/nginx/access.log \
    --error-log-path=/var/nginx/error.log \
    --pid-path=/var/nginx/nginx.pid \
    --lock-path=/var/nginx/nginx.lock \
    --with-luajit \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    --without-http_ssi_module \
    --without-http_userid_module \
    --without-http_fastcgi_module \
    --without-http_uwsgi_module \
    --without-http_scgi_module \
    --without-http_memcached_module \
    -j${NPROC} \
 && echo "==> Building OpenResty..." \
 && make -j${NPROC} \
 && echo "==> Installing OpenResty..." \
 && make install \
 && echo "==> Finishing..." \
 && ln -sf /opt/openresty/nginx/sbin/nginx /usr/local/bin/nginx \
 && ln -sf /opt/openresty/nginx/sbin/nginx /usr/local/bin/openresty \
 && ln -sf /opt/openresty/bin/resty /usr/local/bin/resty \
 && ln -sf /opt/openresty/luajit/bin/luajit-* /opt/openresty/luajit/bin/lua \
 && ln -sf /opt/openresty/luajit/bin/luajit-* /usr/local/bin/lua \
 && rm -rf /root/ngx_openresty*

WORKDIR /opt/openresty/nginx/

ONBUILD RUN rm -rf conf/* html/*
ONBUILD COPY nginx /opt/openresty/nginx/

CMD ["nginx", "-g", "daemon off; error_log /dev/stderr info;"]
