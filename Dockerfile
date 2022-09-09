FROM ubuntu:18.04

# Kubeval Version
ARG KUBEVAL_VERSION='v0.16.1'

COPY entrypoint.sh /entrypoint.sh
RUN apt-get update\
    && apt-get install -y curl jq
###################
# Install Kubeval #
###################
RUN curl -L --output kubeval-linux-amd64.tar.gz https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz \
    && tar xf kubeval-linux-amd64.tar.gz \
    && mv kubeval /usr/local/bin \
    && rm kubeval-linux-amd64.tar.gz

WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
