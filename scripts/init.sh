#!/bin/bash
#Init

pixivDomain=$PIXIV_DOMAIN
pximgDomain=$PXIMG_DOMAIN
port=$PORT
port2=$PORT2
if [[ ${PORT2} ]]; then enable_https=0; else enable_https=1; fi
enable_ipset=$BLOCK_IP
if [[ -z "${pixivDomain}" || -z "${pximgDomain}" ]]
then
    echo -e "\033[31m [ERR]Cannot read the env!Have you set them? \033[0m"
    exit 1
fi
if [[ -z "$port" ]]
then
    port=8080
fi
pixivDomain2='~^([^.]+)\\.'${pixivDomain//'.'/'\\.'}'$'
pximgDomain2='~^([^.]+)\\.'${pximgDomain//'.'/'\\.'}'$'

echo "Start init"
printf "*.pixiv.net ==> *.%s *.pximg.net ==> *.%s\n" $pixivDomain $pximgDomain
printf "The program will run on port %s" $port
if [[ $enable_https ]]; then printf "and %s.\n" $port2; else printf ".\n"; fi
echo "Copy nginx.conf..."
if [[ $enable_https ]]
then
    cp ./nginx_https.conf /etc/nginx/nginx.conf
else
    cp ./nginx_http.conf /etc/nginx/nginx.conf
fi
echo "Done."
echo "Replace the domain..."
sed -i "s/@PIXIV_DOMAIN@/${pixivDomain}/g" /etc/nginx/nginx.conf
sed -i "s/@PIXIV_DOMAIN2@/${pixivDomain2}/g" /etc/nginx/nginx.conf
sed -i "s/@PXIMG_DOMAIN@/${pximgDomain}/g" /etc/nginx/nginx.conf
sed -i "s/@PXIMG_DOMAIN2@/${pximgDomain2}/g" /etc/nginx/nginx.conf
echo "Done."
echo "Replace the ports..."
sed -i "s/@PORT2@/${port2}/g" /etc/nginx/nginx.conf
sed -i "s/@PORT@/${port}/g" /etc/nginx/nginx.conf
echo "Done."
echo "Test nginx config..."
nginx -t
if [[ $? = 0 ]]
then
    echo "Success!"
    echo "Start nginx..."
    service nginx start
    if [[ $? != 0 ]]
    then
        echo -e "\033[31m [ERR]Start nginx failed! \033[0m"
        exit 1
    fi
    service nginx reload
    echo "Done."
else
    exit 1
fi
if [[ $enable_https ]]
then
    echo "Unmask SSL certificate configuration..."
    sed -i "s/#@ssl_certificate@/ssl_certificate/g" /etc/nginx/nginx.conf
    echo "Done."
    echo "Start getting SSL..."
    if [[ ${SSL_MODE,,} = "git" ]]
    then
        ./scripts/ssl_git.ssh
    else
        ./scripts/ssl_acme.sh
    fi
    if [ $? != 0 ]
    then
        echo "Success!"
    else
        echo -e "\033[31 mFail! \033[0m"
        exit 1
    fi
else
    echo -e "\033[33m Skip SSL configuration. \033[0m"
fi
if [[ $enable_ipset ]]
then
    echo "Block the IP outside the China..."
    if ./scripts/ipset.sh
    then
        echo "Done."
    else
        echo -e "\033[31m Error to setup! \033[0m"
        exit 1
    fi
else
    echo -e "\033[33m Skip IP-Block. \033[0m"
fi
echo -e "\033[36m All DOne! \033[0m"
echo -e "Quit!"
exit 0