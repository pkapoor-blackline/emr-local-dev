## Enable SSH access ##

echo "Running as `whoami`"
echo "Running init ssh script"

touch ~/.bashrc
echo "export VSCODE_SERVER_CUSTOM_GLIBC_LINKER=$HOME/.vscode-server/sysroot/lib/ld-linux-x86-64.so.2" >> ~/.bashrc
echo "export VSCODE_SERVER_CUSTOM_GLIBC_PATH=$HOME/.vscode-server/sysroot/usr/lib:$HOME/.vscode-server/sysroot/lib" >> ~/.bashrc
echo "export VSCODE_SERVER_PATCHELF_PATH=$HOME/.vscode-server/sysroot/usr/bin/patchelf" >> ~/.bashrc

mkdir -p /home/hadoop/.vscode-server/sysroot
tar zxf /home/hadoop/vscode-sysroot-x86_64-linux-gnu.tgz -C ~/.vscode-server

sudo yum install -y openssh-server && \
    sudo ssh-keygen -A && \
    echo "hadoop ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

sudo mkdir -p /var/run/sshd
mkdir -p /home/hadoop/.ssh && chmod 700 /home/hadoop/.ssh

cat /home/hadoop/id_rsa.pub > /home/hadoop/.ssh/authorized_keys && tail -2 /home/hadoop/.ssh/authorized_keys
chown -R hadoop:hadoop /home/hadoop/.ssh && chmod 600 /home/hadoop/.ssh/authorized_keys

sudo /usr/sbin/sshd -D -e
while sleep 1000; do :; done
