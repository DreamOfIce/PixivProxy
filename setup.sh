#!/bin/bash
#Run this script on VPS

echo -e "\033[33m Pixiv Proxy\n \033[0m"
echo -e "\033[36m Github: https://github.com/Creeper2077/pixiv-proxy-cn \033[0m"
echo -e "\033[33m Please abide by the use agreement of relevant service providers !\033[0m"
echo -e "\n===============================\n"
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
if [ -z $PIXIV_DOMAIN ]
then
echo "Please enter the domain to be used to replace *.pixiv.net:"
read pixivDomain
export PIXIV_DOMAIN="$pixivDomain"
fi
if [ -z $PXIMG_DOMAIN ]
then
echo "Please enter the domain to be used to replace *.pximg.net:"
read pximgDomain
export PXIMG_DOMAIN="$pximgDomain"
fi
if [[ -z $PORT ]]
then
    read -n1 -t30 -p "Do you want to use HTTPS?[y/N]?" input
    if [[ ${input,,} = "y" ]]
    then
	    echo "Using HTTPS."
        echo "Which SSL mode do you want to Choice?"
        echo "[Git mode] Clone SSL cert from private git repo;"
        echo "[ACME mode] Automatically issue SSL certificates from ZeroSSL(acme.sh)."
        read -t15 -p "Input your answer[acme,git]: " input
        if [ ${input,,} = "git" ]
        then
            export SSL_MODE="git"
            read -n2048 -p "Enter the Git URL(like git@xxx.xx:username/repo):" git_url
            export GIT_URL = $git_url
        else
            export SSL_MODE="acme"
            if read -t30 -n100 -p "Enter your e-mail(for issue SSL certs): " input
            then
                export EMAIL=$input
            else
                export EMAIL=$postmaster@example.cn
                echo "Using default."
            fi
        fi
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
    if [[ ${input,,} = "y" ]]
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
