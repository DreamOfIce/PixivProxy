#!/bin/bash
#Run this script on VPS

echo "Pixiv Proxy"
echo "Author:Creeper2077"
echo "Github: https://github.com/Creeper2077/pixiv-proxy-cn"
echo "Using GPL3.0 License"
echo "Please abide by the use agreement of relevant service providers!"
echo "==============================="
echo "Start install."
echo "Update source..."
apt update -qq > /dev/null
echo "Done."
echo "Install Nginx"
apt install curl nginx libnginx-mod-http-subs-filter -y -qq --no-install-recommends > /dev/null
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
apt clean -qq > /dev/null
apt autoremove -qq > /dev/null
echo "done."
echo "Finish!"
read -p "Please enter the name to be used to replace *.pixiv.net:" pixivDomain
read -p "Please enter the name to be used to replace *.pximg.net:" pximgDomain
export PIXIV_DOMAIN=$pixivDomain
export PXIMG_DOMAIN=$pximgDomain
if [ ! $PORT || ! $PORT2 ]
then
    read -p "Do you want to use HTTPS?[y/N]?" -n1 -t30 input
    if [ $input = "Y"|| $input = "y" ]
    then
	    echo "Using HTTPS."
        if  read -p "Input the port of HTTPS:" input -t15 -n5
        then
            export PORT=$input
        else
            export PORT=443
            echo "Using default:443"
        fi
        if  read -p "Input the port of HTTP:" input -t15 -n5
        then
            export PORT2=$input
        else
            export PORT2=80
            echo "Using default:80"
        fi
    else
        echo "Using HTTP."
        if  read -p "Input the port:" input -t15 -n5
        then
            export PORT=$input
        else
            export PORT=80
            echo "Using default:80"
        fi
    fi
fi
if [ ! $BLOCK_IP ]
then
    read -p "Do you wang to block the IP outside Chinese mainland?(If you are using CDN,plase disable this)[y/N]:" -t15 -n1 input
    if [ $input = "Y"|| $input = "y" ]
    then
        export BLOCK_IP=0
    else
        export BLOCK_IP=1
    fi
fi
echo "Run init script..."
./init.sh
echo "Done."
