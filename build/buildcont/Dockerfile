FROM ubuntu:15.10
MAINTAINER Oleksii Dzhulai nixlike@gmail.com

WORKDIR /tmp

RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/' /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install --no-install-recommends -y \
	python-demjson=2.2.2* \
	wget=1.16.1* \
	git=1:2.5.0* \
	ruby=1:2.1.* \
	shellcheck=0.3.7-1 \
	curl=7.43.0-1ubuntu2.1 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
RUN gem install ruby-lint:2.1.0 serverspec:2.29.2 rake:10.5.0

RUN git clone https://github.com/nixlike/ecore && \
	cd ecore &&\
	git checkout 68d5eda9a46ae135dd8c0a425d447bcb98811ea2
