FROM ubuntu:18.04

MAINTAINER "Kuboya"

USER root

RUN apt-get -qq update \
&& apt-get -q -y upgrade \
&& apt-get autoremove --purge \
&& apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib \
build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev \
xterm vim \
locales \
&& rm -rf /var/lib/apt/lists/*

# ロケールの設定
# RUN locale-gen en_US.UTF-8

# COPY ./default_locale /etc/default/locale
# RUN chmod 0755 /etc/default/locale

# RUN dpkg-reconfigure locales \
RUN locale-gen en_US.UTF-8 \
&& update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV PYTHONIOENCODING=utf-8

# RUN echo 'import sys; sys.setdefaultencoding("utf-8")' >> /usr/local/lib/python2.7/sit
# e-packages/sitecustomize.py

# RUN environment=LANG="es_US.utf8", LC_ALL="es_US.UTF-8", LC_LANG="es_US.UTF-8"

RUN git clone git://git.yoctoproject.org/poky -b warrior \
&& cd poky \
&& git clone git://git.yoctoproject.org/meta-raspberrypi -b warrior \
&& git clone git://git.openembedded.org/meta-openembedded -b warrior \
&& git clone git://git.openembedded.org/openembedded-core -b warrior \
&& git clone https://github.com/meta-qt5/meta-qt5 -b warrior \
&& . ./oe-init-build-env

# RUN bitbake-layers add-layer ../meta-openembedded/meta-oe \
# && bitbake-layers add-layer ../meta-openembedded/meta-multimedia \
# && bitbake-layers add-layer ../meta-openembedded/meta-networking \
# && bitbake-layers add-layer ../meta-openembedded/meta-python \
RUN bitbake-layers add-layer ../meta-raspberrypi \
&& bitbake-layers add-layer ../meta-openembedded/meta-oe \
&& bitbake-layers add-layer ../meta-qt5 

#RUN touch conf/sanity.conf

RUN vi ./conf/local.conf \
- MACHINE ??= "qemux86" \
+ MACHINE ??= "raspberrypi2" \
+ DL_DIR ?= "${TOPDIR}/../downloads" \
+ SSTATE_DIR ?= "${TOPDIR}/../sstate-cache" \
+ BB_NUMBER_THREADS = "6" \
+ PARALLEL_MAKE = "-j 6" \
# + GPU_MEM = "128" \
+ LICENSE_FLAGS_WHITELIST += "commercial"

#RUN MACHINE=raspberrypi2 bitbake core-image-base

ENTRYPOINT ["/bin/bash"]

EXPOSE 22

VOLUME /data