FROM alpine:edge
ENV UUID bae4c69e-3fe3-45d4-aaae-43dc34855efc
ENV Path ray
ENV WALLET default_wallet_address
ENV TZ 'Asia/Shanghai'

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
&& apk upgrade --no-cache \
&& apk --update --no-cache add tzdata supervisor ca-certificates python3 nginx build-base cmake git curl wget unzip openssl-dev libmicrohttpd-dev hwloc-dev \
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& cd / \
&& git clone https://github.com/Supervisor/meld3.git \
&& cd meld3 \
&& python3 setup.py install \
&& apk del --purge build-base cmake git \
&& rm -rf /var/cache/apk/*

RUN mkdir -p /usr/bin/v2ray/ \
&& cd /tmp \
&& VER=$(curl -s https://api.github.com/repos/v2ray/v2ray-core/releases/latest | grep tag_name | awk  -F '"' '{print $4}') \
&& wget https://github.com/v2ray/v2ray-core/releases/download/$VER/v2ray-linux-64.zip \
&& unzip v2ray-linux-64.zip \
&& chmod +x v2ray v2ctl \
&& mv v2* /usr/bin/v2ray/ \
&& mv *.dat /usr/bin/v2ray/ \
&& rm -rf v2ray-linux-64.zip /tmp/* \
&& mkdir /var/log/v2ray/  \
&& adduser -D myuser \
&& mkdir /run/nginx

ENV PATH /usr/bin/v2ray:$PATH
COPY default.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisord.conf
COPY config.json /etc/v2ray/config.json
COPY entrypoint.sh /usr/bin/

USER myuser
CMD entrypoint.sh
