FROM alpine:3.22.1 AS builder

RUN apk add xxd gcc make musl-dev
ADD https://github.com/logological/gpp/releases/download/2.28/gpp-2.28.tar.bz2 /tmp
WORKDIR /tmp
RUN tar xjf gpp-2.28.tar.bz2
WORKDIR /tmp/gpp-2.28
RUN ./configure && make && make install


FROM alpine:3.22.1

# Install packages.
RUN apk add python3 lua py3-pillow make

# Copy files.
COPY assets/luapp /usr/local/bin
COPY --from=builder /usr/local/bin/* /usr/local/bin
