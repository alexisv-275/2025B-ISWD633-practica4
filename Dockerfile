FROM centos:7

# Cambiar a los repositorios archivados (vault)
RUN sed -i 's|^mirrorlist=|#mirrorlist=|g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo

RUN yum -y update

RUN yum -y install httpd

COPY ./web /var/www/html

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]