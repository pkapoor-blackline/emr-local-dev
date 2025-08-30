# --- Stage 1: pull EMR Spark bits + entrypoint
FROM 895885662937.dkr.ecr.us-west-2.amazonaws.com/spark/emr-6.7.0:latest

USER root

# -------------------------------------------------------------------
# Hadoop user + sudoers
# -------------------------------------------------------------------
RUN echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chmod 1777 /tmp

# -------------------------------------------------------------------
# Install base build deps 
# -------------------------------------------------------------------
RUN yum install -y gcc gcc-c++ bison flex make gawk wget curl tar gzip bzip2 xz unzip git sudo \
                   texinfo help2man ncurses-devel gperf patch rsync \
                   autoconf automake libtool \
    && yum clean all

# VS Code Fix
RUN yum install -y gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
    python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
    patch rsync meson ninja-build \
    && mkdir -p /opt/toolchain
RUN wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.bz2
RUN tar -xjf crosstool-ng-1.26.0.tar.bz2
RUN cd crosstool-ng-1.26.0 && ./configure --prefix=/crosstool-ng-1.26.0/out && make && make install
ENV PATH=$PATH:/crosstool-ng-1.26.0/out/bin
COPY ./workaround/.configs /opt/toolchain/.config
# RUN cd /opt/toolchain &&   && ct-ng build

# -------------------------------------------------------------------
# Spark configs
# -------------------------------------------------------------------
COPY ./spark/spark-defaults.conf /usr/lib/spark/conf/spark-defaults.conf
COPY ./spark/log4j.properties     /usr/lib/spark/conf/log4j.properties

# -------------------------------------------------------------------
# Python requirements
# -------------------------------------------------------------------
COPY ./pkgs /tmp/pkgs
RUN python3 -m pip install --no-cache-dir boto3 awscli-local \
    && python3 -m pip install --no-cache-dir -r /tmp/pkgs/requirements.txt

USER hadoop
WORKDIR /home/hadoop/

# AWS Vars
ENV AWS_REGION=us-east-1
ENV AWS_PROFILE=datadev

# Bashrc aliases
RUN echo "alias awsExport='eval \$(aws configure export-credentials --profile \${AWS_PROFILE:-datadev} --format env)'" >> /home/hadoop/.bashrc \
    && echo "alias ss='spark-shell'" >> /home/hadoop/.bashrc \
    && chown hadoop:hadoop /home/hadoop/.bashrc

CMD ["bash", "-l"]
