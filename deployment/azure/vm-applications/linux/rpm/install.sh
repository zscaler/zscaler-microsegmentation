mkdir -p /opt/zscaler/var
mv /opt/zscaler/installation/provision_key /opt/zscaler/var
wget -N --secure-protocol=TLSv1_2 --debug --directory-prefix=/opt/zscaler/installation https://eyez-dist.private.zscaler.com/linux/eyez-agentmanager-default-1.el7.x86_64.rpm 
# wget -N --secure-protocol=TLSv1_2 --debug --directory-prefix=/opt/zscaler/installation https://eyez-dist.zpabeta.net/linux/eyez-agentmanager-default-1.el7.x86_64.rpm
yum install --disablerepo=* -y /opt/zscaler/installation/eyez-agentmanager-default-1.el7.x86_64.rpm
