FROM lanmaoly/alpine

RUN apk add --no-cache apache2 apache2-ldap apache2-webdav subversion mod_dav_svn python2 openldap-clients

ADD script /script

RUN mkdir -p /run/apache2 /etc/apache2/auth \
    && sed -i 's/ErrorLog logs\/error.log/ErrorLog \/dev\/stdout/' /etc/apache2/httpd.conf \
    && sed -i 's/    CustomLog logs\/access.log combined/    CustomLog \/dev\/stdout combined/' /etc/apache2/httpd.conf \
    && mv /script/cron-ldap /etc/crontabs/root \
    && mv /script/svn.conf /etc/apache2/svn.conf


#ADD svn.conf /etc/apache2/svn.conf


ENTRYPOINT ["sh", "/script/entrypoint.sh"]
