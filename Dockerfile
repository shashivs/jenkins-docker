FROM jenkins:2.19.1
MAINTAINER shashivs

USER root

# Install sudo to enpower jenkins (will be usefull for running docker in some cases)
RUN apt-get update \
    && apt-get install -y sudo \
    && apt-get install apache2 \
    && service apache2 start
    && rm -rf /var/lib/apt/lists/* \
    && echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# Install Docker prerequisites
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
        lxc

# Install Docker from Docker Inc. repositories.
RUN echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 \
  && apt-get update -qq \
  && apt-get install -qqy lxc-docker

# Create log folders
RUN bash -c 'mkdir -p /var/log/{supervisor,docker,jenkins}'

# Helper scripts
RUN mkdir /opt/bin
COPY scripts/* /opt/bin/
RUN chmod +x /opt/bin/*

# The list of plugins to install
COPY plugins.txt /tmp/

# Add jenkins user to the docker groups so that the jenkins user can run docker without sudo
RUN gpasswd -a jenkins docker

# Install the magic wrapper
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker  \
	&& /bin/sh /usr/local/bin/wrapdocker

# Download plugins and their dependencies
RUN mkdir /usr/share/jenkins/ref/plugins \
        && ( \
            cat /tmp/plugins.txt; \
            unzip -l /usr/share/jenkins/jenkins.war | sed -nr 's|^.*WEB-INF/plugins/(.+?)\.hpi$|\1|p' \
        ) \
        | /opt/bin/resolve_jenkins_plugins_dependencies.py \
        | /opt/bin/download_jenkins_plugins.py

###############################################################################
CMD ["sh", "-c", "FOREGROUND"]

USER jenkins
ENTRYPOINT ["/opt/bin/startupscripts.sh"]
