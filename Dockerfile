FROM registry.access.redhat.com/rhel6.6:latest
MAINTAINER madanam1
LABEL Vendor="RHEL"

ENV APACHE_RUN_USER apache 
ENV APACHE_RUN_GROUP apache 

#ENV http_proxy http://proxy.eu.novartis.net:2011
#ENV https_proxy http://proxy.eu.novartis.net:2011
#ENV HTTP_PROXY http://proxy.eu.novartis.net:2011
#ENV HTTPS_PROXY http://proxy.eu.novartis.net:2011
#ENV no_proxy localhost,.eu.novartis.net,172.30.113.233,127.0.0.1
#ENV NO_PROXY localhost,.eu.novartis.net,172.30.113.233,127.0.0.1

EXPOSE 8081
RUN yum clean all ; yum -y install rpm-build rpmdevtools tar wget zip unzip ksh
RUN yum -y install httpd mod_wsgi mod_ssl
RUN yum install -y python python-psycopg2 python-setuptools
RUN sed -i.orig 's/#ServerName/ServerName/' /etc/httpd/conf/httpd.conf
RUN sed -i 's/Listen 80/Listen 8081/' /etc/httpd/conf/httpd.conf
RUN sed -i 's#ErrorLog .*#ErrorLog /tmp/error_log#' /etc/httpd/conf/httpd.conf
RUN sed -i 's#CustomLog .*#CustomLog /tmp/access_log combined#' /etc/httpd/conf/httpd.conf
RUN sed -i 's#PidFile .*#PidFile /tmp/httpd.pid#' /etc/httpd/conf/httpd.conf
RUN sed -i 's/Listen 443/#Listen 443/' /etc/httpd/conf.d/ssl.conf
COPY default.conf /etc/httpd/conf.d/default.conf
RUN ksh -c 'echo -e "# Web2Py Option:\nWSGISocketPrefix /var/run/wsgi" >> /etc/httpd/conf.d/wsgi.conf'
RUN [ ! -d /var/www/html ] || mkdir -p /var/www/html

#Web2py download
RUN cd /var/www/html && wget https://github.com/web2py/pydal/archive/master.zip -O pydal.zip
RUN cd /var/www/html && unzip pydal.zip  && mv pydal-master pydal
RUN cd /var/www/html/pydal && python setup.py install
RUN cd /var/www/html && wget https://github.com/web2py/web2py/archive/master.zip -O web2py.zip
RUN cd /var/www/html && unzip web2py.zip  && mv web2py-master web2py
RUN cd /var/www/html/web2py && python setup.py install

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
