FROM ubuntu:15.10

WORKDIR /tmp

RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/' /etc/apt/sources.list
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y python-demjson wget git ruby

#RUN wget https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.deb \
#	&& dpkg -i vagrant_1.8.1_x86_64.deb

RUN gem install ruby-lint
