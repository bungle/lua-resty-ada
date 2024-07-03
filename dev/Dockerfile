FROM openresty/openresty:1.21.4.1-focal

ENV DEBIAN_FRONTEND noninteractive
ENV TEST_NGINX_BINARY openresty

USER root
RUN apt-get update && apt-get install -y gcc git cpanminus

RUN git clone https://github.com/Olivine-Labs/busted
RUN cd busted && luarocks make
 
RUN luarocks install inspect
RUN luarocks install lua_pack
RUN luarocks install LuaCov

RUN cpanm --notest Test::Nginx
