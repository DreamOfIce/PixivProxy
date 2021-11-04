#!/bin/bash
#Configune ACME SSL

#install
echo "Get SSL form ZeroSSL!"
echo "Prepare to Install..."
apt update -qq > /dev/null
apt install wget crontab -y -qq --no-install-recommends > /dev/null
echo "Done."
echo "Install acme.sh..."
wget -O -  https://get.acme.sh | sh -s email=$EMAIL
source ~/.bashrc
acme.sh  --register-account  -m $EMAIL --server zerossl
acme.sh --upgrade  --auto-upgrade
echo "Done."

#issue SSL
for((i=1;i<=5;i++))
do
    echo "Wait 5 minutes for the DNS record to take effect.Press any key to skip!"
    wait(300)
    echo "Start to issue the cert..."
    acme.sh --issue --webroot /var/www/html \
    -d "${PIXIV_DOMAIN}" \
    -d "www.${PIXIV_DOMAIN}" \
    -d "accounts.${PIXIV_DOMAIN}" \
    -d "source.${PIXIV_DOMAIN}" \
    -d "imp.${PIXIV_DOMAIN}" \
    -d "archive.${PIXIV_DOMAIN}" \
    -d "blog.${PIXIV_DOMAIN}" \
    -d "chat.${PIXIV_DOMAIN}" \
    -d "help.${PIXIV_DOMAIN}" \
    -d "link.${PIXIV_DOMAIN}" \
    -d "m.${PIXIV_DOMAIN}"
    code=$?
    acme.sh --issue --webroot /var/www/html \
    -d "${PXIMG_DOMAIN}" \
    -d "www.${PXIMG_DOMAIN}" \
    -d "i.${PXIMG_DOMAIN}" \
    -d "s.${PXIMG_DOMAIN}" \
    -d "pixiv.${PXIMG_DOMAIN}"
    if [ $? -eq 0 && $code -eq 0 ]
    then
        echo "Done."
        break
    elif [ i==5 ]
        echo -e "\033[31m Issue ail for five times,Quit! \033[0m"
        exit 1
    else
        echo -e "\033[31m Fail!Are you sure all the domains point to this server? \033[0m"
    fi
done
#install SSL
echo "Install cert..."
if [ ! -e /etc/nginx/cert ]
then
    mkdir /etc/nginx/cert
fi
acme.sh --install-cert -d "{$PIXIV_DOMAIN}" \
--key-file       /etc/nginx/cert/${$PIXIV_DOMAIN}.crt  \
--fullchain-file /etc/nginx/cert/${$PIXIV_DOMAIN}.key
acme.sh --install-cert -d "${PXIMG_DOMAIN}" \
--key-file       /etc/nginx/cert/${$PXIMG_DOMAIN}.crt  \
--fullchain-file /etc/nginx/cert/${$PXIMG_DOMAIN}.key \
--reloadcmd     "nginx -t && service nginx force-reload"
echo "Done."
echo -e "\033[36m Successful configune SSL! \033[0m"
exit 0

#functions
wait(){
    for((j=0;j<$1;j++))
    do
        if read -p "." -n1 -t1 -s input
        then
            break
        fi
    done
}