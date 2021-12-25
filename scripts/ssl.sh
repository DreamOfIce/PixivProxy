#!/bin/bash
#Configune SSL

#读取配置
source ../_config

#安装acme.sh
echo "安装acme.sh..."
curl https://get.acme.sh | sh
source ~/.bashrc
acme.sh --upgrade --auto-upgrade
echo "完成."

#注册账户
acme.sh --set-default-ca --server zerossl
acme.sh --register-account -m ${email}

#申请证书
base64 -d ${dnsExport} | sh
acme.sh --issue -dns ${dns} -d "*.${pixivDomain}" -d "*.${pximgDomain}"

#安装证书
echo "取消注释SSL相关配置..."
sed -i "s/#@ssl@//g" /etc/nginx/sites-available/proxy.conf
echo "完成."
echo "安装SSL证书..."
if [ ! -e /etc/nginx/cert ]; then
    mkdir /etc/nginx/cert/
fi
acme.sh --install-cert -d "*.${pixivDomain}" \
    --key-file /etc/nginx/cert/${pixivDomain}.key \
    --fullchain-file /etc/nginx/cert/${pixivDomain}.crt \
    --reloadcmd "nginx -t && service nginx force-reload"
echo "完成."
