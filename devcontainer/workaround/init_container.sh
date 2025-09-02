## Enable SSH access ##

echo "Running as `whoami`"
echo "Running init ssh script"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

touch ~/.bashrc
echo "export VSCODE_SERVER_CUSTOM_GLIBC_LINKER=$HOME/.vscode-server/sysroot/lib/ld-linux-x86-64.so.2" >> ~/.bashrc
echo "export VSCODE_SERVER_CUSTOM_GLIBC_PATH=$HOME/.vscode-server/sysroot/usr/lib:$HOME/.vscode-server/sysroot/lib" >> ~/.bashrc
echo "export VSCODE_SERVER_PATCHELF_PATH=$HOME/.vscode-server/sysroot/usr/bin/patchelf" >> ~/.bashrc

mkdir -p /home/hadoop/.vscode-server/sysroot
tar zxf ${SCRIPT_DIR}/vscode-sysroot/toolchain/vscode-sysroot-x86_64-linux-gnu.tgz -C ~/.vscode-server 2>/dev/null

sudo yum install -y openssh-server && \
    sudo ssh-keygen -A && \
    sudo echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

sudo mkdir -p /var/run/sshd
mkdir -p /home/hadoop/.ssh && chmod 700 /home/hadoop/.ssh

cat /home/hadoop/id_rsa.pub > /home/hadoop/.ssh/authorized_keys && tail -2 /home/hadoop/.ssh/authorized_keys
chown -R hadoop:hadoop /home/hadoop/.ssh && chmod 600 /home/hadoop/.ssh/authorized_keys

echo "Adding hadoop to group 1002"
sudo groupadd -g 1002 local_users 2>/dev/null
sudo usermod -a local_users hadoop 2>/dev/null
sudo usermod -g local_users hadoop 2>/dev/null

sudo su hadoop
groups hadoop

echo "Fixing permissions"
# add write access of a folder to the group
sudo chmod -R g+rwx /home/hadoop/workspace/ >> /home/hadoop/permissions.out 2>&1
# add read access of the .aws folder to the group
sudo chmod -R g+rx /home/hadoop/.aws >> /home/hadoop/permissions.out 2>&1
sudo chmod -R g+rx /home/hadoop/.ssh >> /home/hadoop/permissions.out 2>&1

sudo /usr/sbin/sshd -D -e
while sleep 1000; do :; done
