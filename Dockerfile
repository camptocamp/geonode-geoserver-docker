FROM tomcat:9-jre8

MAINTAINER francois.vanderbiest@camptocamp.com

#
# Set GeoServer version and data directory
#
ENV GEOSERVER_VERSION=2.9.x

#
# Download and install GeoServer
#

# TODO: once it works, copy those remote resources locally.
RUN wget --progress=bar:force:noscroll http://build.geonode.org/geoserver/latest/geoserver-${GEOSERVER_VERSION}.war -O /geoserver.war \
    && unzip -q /geoserver.war -d /usr/local/tomcat/webapps/geoserver \
    && rm -rf /geoserver.war /usr/local/tomcat/webapps/geoserver/data

RUN wget --progress=bar:force:noscroll http://build.geonode.org/geoserver/latest/data-${GEOSERVER_VERSION}.zip -O /data.zip \
    && unzip -q /data.zip -d /usr/local/tomcat/webapps/geoserver/data \
    && rm -f /data.zip

VOLUME [ "/usr/local/tomcat/webapps/geoserver/data" ]

COPY scripts/*.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["catalina.sh", "run"]
