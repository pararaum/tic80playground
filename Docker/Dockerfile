FROM alpine:3.22.1 AS builder

RUN apk add xxd gcc make musl-dev
ADD https://github.com/logological/gpp/releases/download/2.28/gpp-2.28.tar.bz2 /tmp
WORKDIR /tmp
RUN tar xjf gpp-2.28.tar.bz2
WORKDIR /tmp/gpp-2.28
RUN ./configure && make && make install


FROM alpine:3.22.1

# Install packages.
RUN apk add python3 lua py3-pillow make && \
    mkdir -p /usr/include/t7d/effects

# Copy files.
COPY assets/* /usr/local/bin
COPY Engine/*.inc.lua /usr/include/t7d
COPY Engine/effects/*.lua /usr/include/t7d/effects
COPY --from=builder /usr/local/bin/* /usr/local/bin
