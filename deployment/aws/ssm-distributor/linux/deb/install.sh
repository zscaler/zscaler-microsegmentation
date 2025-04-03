mkdir -p /opt/zscaler/var
mv provision_key /opt/zscaler/var
wget -N --secure-protocol=TLSv1_2 --debug --directory-prefix=/opt/zscaler/installation https://eyez-dist.private.zscaler.com/linux/eyez-agentmanager-default-1.amd64.deb
# wget -N --secure-protocol=TLSv1_2 --debug --directory-prefix=/opt/zscaler/installation https://eyez-dist.zpabeta.net/linux/eyez-agentmanager-default-1.amd64.deb
apt install -y /opt/zscaler/installation/eyez-agentmanager-default-1.amd64.deb
