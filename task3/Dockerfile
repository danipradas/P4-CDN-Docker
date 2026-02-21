FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y wget unzip python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/bento4.zip https://www.bok.net/Bento4/binaries/Bento4-SDK-1-6-0-641.x86_64-unknown-linux.zip && \
    unzip /tmp/bento4.zip -d /opt/ && \
    ln -s /opt/Bento4-SDK-1-6-0-641.x86_64-unknown-linux /opt/bento4 && \
    rm /tmp/bento4.zip

ENV PATH="/opt/bento4/bin:/opt/bento4/utils:${PATH}"

WORKDIR /media