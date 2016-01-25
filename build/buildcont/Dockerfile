FROM ubuntu:15.10
MAINTAINER Oleksii Dzhulai nixlike@gmail.com

WORKDIR /tmp

RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/' /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install --no-install-recommends -y \
	python-demjson=2.2.2* \
	wget=1.16.1* \
	git=1:2.5.0* \
	ruby=1:2.1.* \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
RUN gem install ruby-lint
