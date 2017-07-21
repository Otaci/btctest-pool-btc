FROM alpine
MAINTAINER Otaci <otaci@protonmail.com>

ARG USER_ID
ARG GROUP_ID

ENV HOME /eloipool

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

WORKDIR /eloipool

# install eloipool
RUN apk --no-cache upgrade \
	&& apk --no-cache add python3=3.6.1-r2 \
	&& apk --no-cache add --virtual build-dependencies git build-base python3-dev=3.6.1-r2 \
	&& cd /eloipool \
	&& git clone https://github.com/jgarzik/python-bitcoinrpc.git \
	&& git clone https://gitorious.org/bitcoin/python-base58.git \
	&& git clone https://gitorious.org/midstate/midstate.git \
	&& git clone https://gitorious.org/bitcoin/eloipool.git \
	&& cd midstate && sed -i ':a;N;$!ba;s/\-lpython3.2\n/\-lpython3.6m\n/' Makefile \
	&& sed -i ':a;N;$!ba;s/\-I\/usr\/include\/python3.2\n/\-I\/usr\/include\/python3.6m\n/' Makefile \
	&& make

RUN cd /eloipool/eloipool \
	&& ln -s ../midstate/midstate.so midstate.so \
	&& ln -s ../python-base58/base58.py base58.py \
	&& ln -s ../python-bitcoinrpc/bitcoinrpc/ bitcoinrpc \
	&& ln -s ../python-bitcoinrpc/jsonrpc/ jsonrpc


# cleanup
RUN apk del build-dependencies \
	&& rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

ADD ./bin /usr/local/bin

EXPOSE 3334
CMD run-eloipool.sh
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

