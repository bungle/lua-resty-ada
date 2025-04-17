FROM openresty/openresty:noble

ENV DEBIAN_FRONTEND noninteractive
ENV TEST_NGINX_BINARY openresty

USER root

RUN apt update
RUN apt install -y gcc git cmake lua5.1 liblua5.1-dev luarocks
RUN luarocks --lua-version 5.1 install luacheck
RUN luarocks --lua-version 5.1 install busted
RUN luarocks --lua-version 5.1 install LuaCov
