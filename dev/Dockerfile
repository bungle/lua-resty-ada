FROM openresty/openresty:1.27.1.2-0-noble

ENV DEBIAN_FRONTEND noninteractive
ENV TEST_NGINX_BINARY openresty

USER root

RUN apt update
RUN apt install -y gcc git cmake
RUN luarocks install luacheck
RUN luarocks install busted
RUN luarocks install LuaCov
