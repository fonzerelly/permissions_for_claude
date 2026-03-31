FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        bats \
        sudo \
        openssh-client \
    && rm -rf /var/lib/apt/lists/*
