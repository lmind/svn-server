FROM lanmaoly/alpine

RUN apk add --no-cache apache2 apache2-ldap apache2-webdav subversion mod_dav_svn

RUN mkdir -p /run/apache2

ADD entrypoint.sh /entrypoint.sh
ADD svn.conf /etc/apache2/conf.d/svn.conf

ENTRYPOINT ["/entrypoint.sh"]
