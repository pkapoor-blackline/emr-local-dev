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
RUN echo "AWS_PROFILE=datadev" >> /home/hadoop/.bashrc \
    && echo "AWS_REGION=us-east-1" >> /home/hadoop/.bashrc \
    && echo "alias awsExport='eval \$(aws configure export-credentials --profile \${AWS_PROFILE:-datadev} --format env)'" >> /home/hadoop/.bashrc \
    && echo "alias ss='spark-shell --master local[*] --conf spark.sql.shuffle.partitions=10'" >> /home/hadoop/.bashrc \
    && echo "alias ss_delta='spark-shell --master local[*] --packages io.delta:delta-core_2.12:2.0.2,org.apache.hadoop:hadoop-aws:3.2.1 --conf spark.delta.logStore.class=org.apache.spark.sql.delta.storage.S3SingleDriverLogStore --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.sql.shuffle.partitions=10'" >> /home/hadoop/.bashrc \
    && chown hadoop:hadoop /home/hadoop/.bashrc

CMD ["bash", "-l"]
