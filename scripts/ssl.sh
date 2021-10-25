#!/bin/bash
#Configune SSL

#Install
echo "Prepare to Install..."
apt update -qq > /dev/null
apt install curl crontab -y -qq --no-install-recommends > /dev/null
echo "Done."
echo "Install acme.sh..."
read -p "Enter your e-mail(for SSL certs): " -t30 -n100 ssl_email
    if [ $ssl_email ]; then echo "Using default email."; ssl_email='admin@my-pixiv.cn'; fi
printf "\n"
curl  https://get.acme.sh | sh -s email=$ssl_email
${HOME}/.acme.sh/acme.sh--upgrade  --auto-upgrade
echo "Done."

#Issue SSL
for((i=1;i<=5;i++))
do
    echo "Wait 5 minutes for the DNS record to take effect.Press any key to skip!"
    for((i=0;i<=300;i++))
    do
        if read -p "." -n1 -t1 -s input
        then
        break
        fi
    done
    echo "Start to issue the cert..."
    if ${HOME}/.acme.sh/acme.sh --issue  -d "*.$PIXIV_DOMAIN" -d "*.$PXIMG_DOMAIN"  --webroot /var/www/html
    then
    echo "Done."
    break
    else
    echo "Fail!Are you sure the domains $PIXIV_DOMAIN and $PXIMG_DOMAIN points to this server?"
    fi
    if [ i==5 ]; then exit 1; fi
done
#Install SSL
echo "Install cert"
if [ ! -e /etc/nginx/cert ]
then
    mkdir /etc/nginx/cert
fi
${HOME}/.acme.sh/acme.sh--install-cert -d "*.$PIXIV_DOMAIN" \
--key-file       /etc/nginx/cert/pixiv_key.pem  \
--fullchain-file /etc/nginx/cert/pixiv_cert.pem
${HOME}/.acme.sh/acme.sh--install-cert -d "*.$PXIMG_DOMAIN" \
--key-file       /etc/nginx/cert/pximg_key.pem  \
--fullchain-file /etc/nginx/cert/pximg_cert.pem \
--reloadcmd     "nginx -t && service nginx force-reload"
echo "Done."
echo "Successful configune SSL!"
exit 0