FROM jenkins:2.19.1
MAINTAINER shashivs

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install sudo to enpower jenkins (will be usefull for running docker in some cases)
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get install -y sudo \
    && apt-get install -y openssh-server  \
    && apt-get install -y apache2 \
    && apt-get install -y supervisor vim \
    && apt-get install -y apt-transport-https \
    	ca-certificates lxc iptables wget curl \
    && mkdir -p /var/lock/apache2 /var/run/apache2 \
    && rm -rf /var/lib/apt/lists/* \
    && echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# Install Docker from Docker Inc. repositories.
RUN echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9 \
  && apt-get update -qq \
  && apt-get install -qqy lxc-docker 

# Create log folders
RUN bash -c 'mkdir -p /var/log/{supervisor,docker,jenkins} /var/lock/apache2 /var/run/{apache2,sshd} /opt/bin'

# Helper scripts
COPY scripts/* /opt/bin/
RUN chmod +x /opt/bin/*

# The list of plugins to install
COPY plugins.txt /tmp/

# Download plugins and their dependencies
RUN mkdir /usr/share/jenkins/ref/plugins \
        && ( \
            cat /tmp/plugins.txt; \
            unzip -l /usr/share/jenkins/jenkins.war | sed -nr 's|^.*WEB-INF/plugins/(.+?)\.hpi$|\1|p' \
        ) \
        | /opt/bin/resolve_jenkins_plugins_dependencies.py \
        | /opt/bin/download_jenkins_plugins.py 



# Add jenkins user to the docker groups so that the jenkins user can run docker without sudo
RUN gpasswd -a jenkins docker


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Install the magic wrapper
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker  

CMD ["/usr/bin/supervisord"]

