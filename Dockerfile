FROM openjdk:alpine

ARG JMETER_VERSION="3.0"
ENV JMETER_HOME /opt/apache-jmeter-${JMETER_VERSION}
ENV	JMETER_BIN	${JMETER_HOME}/bin
#ENV	JMETER_DOWNLOAD_URL  http://mirrors.ocf.berkeley.edu/apache/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz
ENV JMETER_DOWNLOAD_URL https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz

# Install extra packages
# See https://github.com/gliderlabs/docker-alpine/issues/136#issuecomment-272703023
RUN    apk update \
	&& apk upgrade \
	&& apk add ca-certificates \
	&& update-ca-certificates \
	&& apk add --update openjdk8-jre tzdata curl unzip bash xmlstarlet \
	&& rm -rf /var/cache/apk/* \
	&& mkdir -p /tmp/dependencies  \
	&& curl -L --silent ${JMETER_DOWNLOAD_URL} >  /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz  \
	&& mkdir -p /opt \
	&& tar -xzf /tmp/dependencies/apache-jmeter-${JMETER_VERSION}.tgz -C /opt  \
	&& rm -rf /tmp/dependencies

# Set global PATH such that "jmeter" command is found
ENV PATH $PATH:$JMETER_BIN

# Entrypoint utilizes environmental variables to specify the appropriate arguments
# for the Jmeter JMX and various property files governing it's execution.
COPY entrypoint /
RUN chmod +x /entrypoint
RUN mkdir -p /opt/load
COPY load-users.sh /opt/load
RUN chmod +x /opt/load/load-users.sh

# Copy all of the load tests
ADD load /opt/load

WORKDIR	${JMETER_HOME}

ENTRYPOINT ["/entrypoint"]