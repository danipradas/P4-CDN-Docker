FROM ubuntu:24.04

RUN apt-get update && \
    apt-get install -y ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["ffmpeg"]