# This is a Dockerfile to create a Unifield Environment on Ubuntu 10.04
#
# VERSION 1.0

# use Ubuntu 10.04 image provided by docker.io
FROM ubuntu:10.04

MAINTAINER Quentin THEURET, qt@tempo-consulting.fr

# Get noninteractive frontend for Debian to avoid some problems:
#    debconf: unable to initialize frontend: Dialog
ENV DEBIAN_FRONTEND noninteractive

# Ensure we create the cluster with UTF-8 locale
# Bug: https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/813398
RUN locale-gen en_US.UTF-8 && \
    echo 'LANG="en_US.UTF-8"' > /etc/default/locale

# Set the locale
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
# for root user ~ should be /root
ENV HOME ""

# Add OVH mirror list to update Ubuntu 10.04 to the last version.
# WARNING: Use of udev hold and initscripts hold and upstart hold will prevent:
#    dpkg: error processing udev
#    mount: permission denied
RUN echo "deb http://old-releases.ubuntu.com/ubuntu lucid main restricted" > /etc/apt/sources.list; \
 echo "deb http://old-releases.ubuntu.com/ubuntu/ lucid-updates main restricted" >> /etc/apt/sources.list; \
 echo "deb http://old-releases.ubuntu.com/ubuntu/ lucid multiverse" >> /etc/apt/sources.list; \
 echo "deb http://old-releases.ubuntu.com/ubuntu/ lucid-updates multiverse" >> /etc/apt/sources.list; \
 echo "deb http://old-releases.ubuntu.com/ubuntu/ lucid universe" >> /etc/apt/sources.list; \
 echo "deb http://old-releases.ubuntu.com/ubuntu/ lucid-updates universe" >> /etc/apt/sources.list; \
 echo udev hold | dpkg --set-selections; \
 echo initscripts hold | dpkg --set-selections; \
 echo upstart hold | dpkg --set-selections; \
 apt-get update; \
 apt-get upgrade -y

# Install postgresql, ssh server (access to the container), supervisord (to launch services), 
#+ tmux (to not open a lot of ssh connections), zsh and vim (to work into the container),
#+ bzr and python-argparse (for MKDB script), ipython (for a better Python console)
RUN apt-get install -y openssh-server \
        postgresql-8.4 \
        supervisor \
        screen \
        tmux  \
        vim \
        bzr \
        python-argparse \
        ipython \
        wget \
        diffstat \
        zip \
        git-core \
        apache2-mpm-prefork \
        libapache2-mod-wsgi \
        psmisc \
        build-essential \
        postfix \
        cron

# CONFIGURATION
RUN mkdir -p /var/run/sshd
RUN mkdir -p /var/log/supervisor

# Add OpenERP dependancies
RUN apt-get install -y python \
        python-psycopg2 \
        python-reportlab \
        python-egenix-mxdatetime \
        python-tz \
        python-pychart \
        python-pydot \
        python-lxml \
        python-libxslt1 \
        python-vobject \
        python-imaging \
        python-profiler \
        python-setuptools \
        python-yaml \
        python-ldap \
        python-cherrypy3 \
        python-mako \
        python-simplejson \
        python-formencode \
        python-pybabel \
        python-pip \
        wkhtmltopdf \
        python-xlwt \
        python-dev \
        python-openssl \
        python-httplib2 \
        libffi-dev

# testfield
RUN apt-get install -y pkg-config \
        python-matplotlib \
        python-numpy \
        python-mock \
        python-levenshtein \
        firefox \
        xvfb

# UF
# Nightmare to update setuptools with pip or easy_install
RUN easy_install https://pypi.python.org/packages/00/d7/5511e82e0645ed4b939bb42f0a07450d0cdf9cf3ed08758b459f3d002747/setuptools-20.9.0.tar.gz#md5=e5f4d80fcb68bcac179b327bf1791dec
RUN pip install -q requests
RUN pip install -q OERPLib==0.8.3
RUN pip install -q six==1.10.0
RUN pip install -q ordereddict
RUN pip install -q jira==0.50
RUN pip install -q cffi==1.8.3
RUN pip install -q bcrypt==3.1.1
RUN pip install -q passlib==1.6.5
RUN pip install -q easywebdav==1.2.0

# testfield
#RUN easy_install -U distribute
RUN pip install -q bottle==0.12.9
RUN pip install -q lettuce==0.2.21
RUN pip install -q selenium==2.53.1

ADD faketime.zip /root/faketime.zip
RUN cd /root \
    && unzip faketime.zip \
    && cd libfaketime-master \
    && make install

# apache as RB proxy
RUN a2enmod rewrite
RUN a2enmod headers
RUN a2enmod wsgi
RUN a2enmod proxy
RUN a2enmod proxy_http

# Decomment the next line if you want to use Eclipse and X11 capabilities
#RUN apt-get install -y eclipse


# Add configuration file to launch
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD vimrc.local /etc/vim/vimrc.local
ADD screenrc /root/.screenrc
ADD tmux.conf /root/.tmux.conf
RUN mkdir /root/.ssh && chmod 700 /root/.ssh
ADD authorized_keys /root/.ssh/authorized_keys

# template user used by init RB script
RUN useradd --create-home --shell /bin/bash template

# postfix config
RUN postconf -e inet_interfaces=loopback-only

# apache config
RUN mkdir /var/run/apache2 && chown www-data.www-data /var/run/apache2 && chmod 700 /var/run/apache2

# postgres config
USER postgres
RUN /etc/init.d/postgresql-8.4 start &&\
    createuser -s root

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql", "/etc/apache", "/home"]

# Install RB scripts
USER root
RUN bzr branch lp:unifield-toolbox /opt/unifield-toolbox
RUN ln -s /opt/unifield-toolbox/RB/RBTools/ /root/
RUN ln -s /opt/unifield-toolbox/RB/Sync_Init/ /root/
#ADD RBconfig /root/RBconfig

# Launch supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
