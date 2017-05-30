FROM tomcat:9-jre8

MAINTAINER francois.vanderbiest@camptocamp.com

#
# Set GeoServer version and data directory
#
ENV GEOSERVER_VERSION=2.9.x
ENV DJANGO_URL=http://django:8000/

#
# Download and install GeoServer
#

# TODO: once it works, copy those remote resources locally.
RUN wget --progress=bar:force:noscroll http://build.geonode.org/geoserver/latest/geoserver-${GEOSERVER_VERSION}.war -O /geoserver.war \
    && unzip -q /geoserver.war -d /usr/local/tomcat/webapps/geoserver \
    && rm -rf /geoserver.war /usr/local/tomcat/webapps/geoserver/data \
    && ln -s /mnt/geoserver_datadir /usr/local/tomcat/webapps/geoserver/data

RUN wget --progress=bar:force:noscroll http://build.geonode.org/geoserver/latest/data-${GEOSERVER_VERSION}.zip -O /data.zip \
    && mkdir /mnt/geoserver_datadir.orig \
    && unzip -q /data.zip -d /mnt/geoserver_datadir.orig/ \
    && mv /mnt/geoserver_datadir.orig/data/* /mnt/geoserver_datadir.orig/ \
    && rmdir /mnt/geoserver_datadir.orig/data/ \
    && rm -f /data.zip \
    && sed -i.bak 's@<baseUrl>\([^<][^<]*\)</baseUrl>@<baseUrl>'"$DJANGO_URL"'</baseUrl>@'\
                  /mnt/geoserver_datadir.orig/security/auth/geonodeAuthProvider/config.xml

ENV JAVA_OPTS=-DGEOSERVER_DATA_DIR=/mnt/geoserver_datadir

VOLUME [ "/mnt/geoserver_datadir" ]

COPY docker-entrypoint.d/* /docker-entrypoint.d/
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh
# Change user that run tomcat to UID 999

RUN addgroup --system --gid 999 tomcat \
    && adduser --system --home /usr/local/tomcat --no-create-home --uid 999 --ingroup tomcat --disabled-login tomcat \
    && chown -R tomcat:tomcat /usr/local/tomcat

#USER tomcat

ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD ["catalina.sh", "run"]
