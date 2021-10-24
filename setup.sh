#!/bin/bash
#Run this script on VPS

echo "Pixiv Proxy"
echo "Author:Creeper2077"
echo "Github: https://github.com/Creeper2077/pixiv-proxy-cn"
echo "Using GPL3.0 License"
echo "Please abide by the use agreement of relevant service providers!"
echo "==============================="
echo "Start building image."
echo "Update source..."
apt update -qq
apt upgrade -y -qq
echo "Done."
echo "Install Nginx"
apt install curl nginx libnginx-mod-http-subs-filter -y -qq --no-install-recommends
echo "Done."
echo "Add user www..."
groupadd -r www
useradd -r -g www www
echo "Done."
echo "Copy files..."
cp nginx.conf /etc/nginx/nginx.conf
echo "Done."
echo "Run final processing..."
chmod +x init.sh
apt clean -qq
apt autoremove -qq
echo "done."
echo "Finish!"
read -p "Please enter the name to be used to replace *.pixiv.net" $pixivDomain
read -p "Please enter the name to be used to replace *.pximg.net" $pximgDomain
export PIXIV_DOMAIN=$pixivDomain
export PXIMG_DOMAIN=$pximgDomain
echo "Run init script..."
./init.sh
echo "Done."
