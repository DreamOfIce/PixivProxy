#!/bin/bash
#Init

pixivDomain=$PIXIV_DOMAIN
pximgDomain=$PXIMG_DOMAIN
port=$PORT
port2=$PORT2
enable_https=-z "${PORT2}"
enable_ipset=$BLOCK_IP
if [[ -z "${pixivDomain}" -o -z "${pximgDomain}" ]]
then
    echo "[ERR]Cannot read the env!Have you set them?"
    exit 1
fi
if [[ -z "$port" ]]
then
    port=8080
fi
pixivDomain2='~^([^.]+)\\.'${pixivDomain//'.'/'\\.'}'$'
pximgDomain2='~^([^.]+)\\.'${pximgDomain//'.'/'\\.'}'$'

echo "Pixiv Proxy"
echo "Author:Creeper2077"
echo "Github: https://github.com/Creeper2077/pixiv-proxy-cn"
echo "Using GPL3.0 License"
echo "Please abide by the use agreement of relevant service providers!"
echo $pixivDomain2 $pximgDomain2
printf "*.pixiv.net ==> *.%s *.pximg.net ==> *.%s\n" $pixivDomain $pximgDomain
printf "The program will run on port %s" $port
if [[ $enable_https ]]; then printf "and %s.\n" $port2; else printf ".\n"; fi
echo "Copy nginx.conf..."
if [[ $enable_https ]]
then
    cp ../nginx_https.conf /etc/nginx/nginx.conf
else
    cp ../nginx_http.conf /etc/nginx/nginx.conf
fi
echo "Done."
echo "Replace the domain..."
sed -i "s/@PIXIV_DOMAIN@/${pixivDomain}/g" /etc/nginx/nginx.conf
sed -i "s/@PIXIV_DOMAIN2@/${pixivDomain2}/g" /etc/nginx/nginx.conf
sed -i "s/@PXIMG_DOMAIN@/${pximgDomain}/g" /etc/nginx/nginx.conf
sed -i "s/@PXIMG_DOMAIN2@/${pximgDomain2}/g" /etc/nginx/nginx.conf
echo "Done."
echo "Replace the ports..."
sed -i "s/@PORT@/${port}/g" /etc/nginx/nginx.conf
sed -i "s/@PORT2@/${port2}/g" /etc/nginx/nginx.conf
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
        echo "[ERR]Start nginx failed!"
        exit 1
    fi
    echo "Done."
else
    exit 1
fi
if [[ $enable_https ]]
then
    echo "Unmask SSL certificate configuration..."
    sed -i "s/#@ssl_certificate@/ssl_certificate/g" /etc/nginx/nginx.conf
    echo "Done."
    echo "Run ssl.sh..."
    if ./ssl.sh
    then
        echo "Success!"
    else
        echo "Fail!"
        exit 1
    fi
fi
if [ $enable_ipset ]
then
    echo "Block the IP outside the China"
    if ./ipset.sh
    then
        echo "Done."
    else
        echo "Error to setup!"
        exit 1
    fi
fi
echo "All Done."
echo -e "Start fetching nginx access logs...\n"
tail -f -n10 /var/log/nginx/access.log
echo -e "\nQuit!"
exit 0