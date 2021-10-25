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
echo "Set Permission..."
chmod -R +x ./scripts
apt clean -qq > /dev/null
apt autoremove -qq > /dev/null
echo -e "Done.\n\n"
echo "Please enter the domain to be used to replace *.pixiv.net:"
read pixivDomain
echo "Please enter the domain to be used to replace *.pximg.net:"
read pximgDomain
export PIXIV_DOMAIN=$pixivDomain
export PXIMG_DOMAIN=$pximgDomain
if [[ -z $PORT || -z $PORT2 ]]
then
    read -n1 -t30 -p "Do you want to use HTTPS?[y/N]?" input
    if [[ $input = "Y" || $input = "y" ]]
    then
	    echo "Using HTTPS."
        if  read -t15 -n5 -p "Input the port of HTTPS:" input
        then
            export PORT=$input
        else
            export PORT=443
            echo "Using default:443"
        fi
        if  read -t15 -n5 -p "Input the port of HTTP:" input
        then
            export PORT2=$input
        else
            export PORT2=80
            echo "Using default:80"
        fi
    else
        echo "Using HTTP."
        if  read -t15 -n5 -p "Input the port:" input
        then
            export PORT=$input
        else
            export PORT=80
            echo "Using default:80"
        fi
    fi
fi
if [[ ! $BLOCK_IP ]]
then
    read -t15 -n1 -p "Do you wang to block the IP outside Chinese?(If you are using CDN,plase disable this)[y/N]:" input
    if [[ $input = "Y"|| $input = "y" ]]
    then
        export BLOCK_IP=0
    else
        export BLOCK_IP=1
    fi
    printf "\n"
fi
echo "Run init script..."
./scripts/init.sh
echo "Done."
