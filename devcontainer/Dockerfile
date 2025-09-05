# --- Stage 1: pull EMR Spark bits + entrypoint
FROM 895885662937.dkr.ecr.us-west-2.amazonaws.com/spark/emr-6.7.0:latest

USER root

# -------------------------------------------------------------------
# Hadoop user + sudoers, plus access etc.
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

# -------------------------------------------------------------------
# Spark configs, these setup some S3 and metastore configs
# -------------------------------------------------------------------
COPY ./spark/spark-defaults.conf /usr/lib/spark/conf/spark-defaults.conf
COPY ./spark/log4j.properties     /usr/lib/spark/conf/log4j.properties

# -------------------------------------------------------------------
# Python requirements
# -------------------------------------------------------------------
COPY ./pkgs /tmp/pkgs
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip \
    && python3 -m pip install --no-cache-dir boto3 awscli-local \
    && python3 -m pip install --no-cache-dir -r /tmp/pkgs/requirements.txt

COPY ./pkgs /tmp/pkgs

USER hadoop
WORKDIR /home/hadoop/

# AWS Vars
ENV AWS_REGION=us-east-1
ENV AWS_PROFILE=datadev

# Bashrc aliases
RUN touch /home/hadoop/.bashrc \
    && chown hadoop:hadoop /home/hadoop/.bashrc

CMD ["bash", "-l"]
