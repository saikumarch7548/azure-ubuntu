FROM centos:7.5.1804
RUN yum -y update && yum install -y gcc-c++ && yum clean all
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh / # backward compatability
RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
