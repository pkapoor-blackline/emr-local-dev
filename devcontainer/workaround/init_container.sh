## Enable SSH access ##

echo "Running as `whoami`"
echo "Running init ssh script"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

touch ~/.bashrc \
    && echo "export VSCODE_SERVER_CUSTOM_GLIBC_LINKER=$HOME/.vscode-server/sysroot/lib/ld-linux-x86-64.so.2" >> ~/.bashrc \
    && echo "export VSCODE_SERVER_CUSTOM_GLIBC_PATH=$HOME/.vscode-server/sysroot/usr/lib:$HOME/.vscode-server/sysroot/lib" >> ~/.bashrc \
    && echo "export VSCODE_SERVER_PATCHELF_PATH=$HOME/.vscode-server/sysroot/usr/bin/patchelf" >> ~/.bashrc \
    && echo "export AWS_PROFILE=datadev" >> /home/hadoop/.bashrc \
    && echo "export AWS_REGION=us-east-1" >> /home/hadoop/.bashrc \
    && echo "export AWS_DEFAULT_REGION=us-east-1" >> /home/hadoop/.bashrc \
    && echo "export AWS_EC2_METADATA_DISABLED=true" >> /home/hadoop/.bashrc \
    && echo "alias awsExport='eval \$(aws configure export-credentials --profile \${AWS_PROFILE:-datadev} --format env)'" >> /home/hadoop/.bashrc \
    && echo "alias ss='spark-shell --master local[*] --conf spark.sql.shuffle.partitions=10'" >> /home/hadoop/.bashrc \
    && echo "alias ss_delta='spark-shell --master local[*] --packages io.delta:delta-core_2.12:2.0.2,org.apache.hadoop:hadoop-aws:3.2.1 --conf spark.delta.logStore.class=org.apache.spark.sql.delta.storage.S3SingleDriverLogStore --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.sql.shuffle.partitions=10'" >> /home/hadoop/.bashrc \

# Bash profile
touch ~/.bash_profile \
    && echo 'if [ -f ~/.bashrc ]; then' >> ~/.bash_profile \
    && echo '    . ~/.bashrc' >> ~/.bash_profile \
    && echo 'fi' >> ~/.bash_profile \

# Need ssh to connect to container
sudo yum install -y openssh-server && \
    sudo ssh-keygen -A && \
    sudo echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

sudo mkdir -p /var/run/sshd
mkdir -p /home/hadoop/.ssh && chmod 700 /home/hadoop/.ssh

# Add public key, and give user permission
cat /home/hadoop/id_rsa.pub > /home/hadoop/.ssh/authorized_keys && tail -2 /home/hadoop/.ssh/authorized_keys
chown -R hadoop:hadoop /home/hadoop/.ssh && chmod 600 /home/hadoop/.ssh/authorized_keys

# Create a group so hadoop user can edit files
echo "Adding hadoop to group 1002"
sudo groupadd -g 1002 local_users 2>/dev/null
sudo usermod -a local_users hadoop 2>/dev/null
sudo usermod -g local_users hadoop 2>/dev/null

# Login as hadoop so groups are refreshed
sudo su hadoop
groups hadoop

# Give all folder group level permissions
echo "Fixing permissions"
# add write access of a folder to the group
sudo chmod -R g+rwx /home/hadoop/workspace/ >> /home/hadoop/permissions.out 2>&1
# add read access of the .aws folder to the group
sudo chmod -R g+rx /home/hadoop/.aws >> /home/hadoop/permissions.out 2>&1
sudo chmod -R g+rx /home/hadoop/.ssh >> /home/hadoop/permissions.out 2>&1
# vscode server dir
sudo chmod -R g+rx /home/hadoop/.vscode-server >> /home/hadoop/permissions.out 2>&1
sudo chown -R hadoop:local_users /home/hadoop/.vscode-server

# Install sysroot for older linux - vs-code issue workaround
mkdir -p /home/hadoop/.vscode-server/sysroot
tar zxf ${SCRIPT_DIR}/vscode-sysroot/toolchain/vscode-sysroot-x86_64-linux-gnu.tgz -C ~/.vscode-server 2>/dev/null

# Start listening to ssh
sudo /usr/sbin/sshd -D -e
while sleep 1000; do :; done
