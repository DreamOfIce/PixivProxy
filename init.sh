#!/bin/bash
#Init

pixivDomain=$PIXIV_DOMAIN
pximgDomain=$PXIMG_DOMAIN
port=$PORT
if [ -z "$pixivDomain" -o -z "$pximgDomain" -o -z "$port" ]
then
    echo "[ERR]Cannot read the env!Have you set them?"
    exit 1
fi
pixivDomain2='~^([^.]+)'${pixivDomain//'.'/'\.'}
pximgDomain2='~^([^.]+)'${pximgDomain//'.'/'\.'}

echo "Pixiv Proxy"
echo "Author:Creeper2077"
echo "Github: https://github.com/Creeper2077/pixiv-proxy-cn"
echo "Using GPL3.0 License"
echo "Please abide by the use agreement of relevant service providers!"
printf "*.pixiv.net ==> *.%s *.pximg.net ==> *.%s\n" $pixivDomain $pximgDomain
printf "The program will run on port %s\n" $port
echo "Replace the domain..."
sed -i "s/@PIXIV_DOMAIN@/${pixivDomain}/g" /etc/nginx/nginx.conf
sed -i "s/@PIXIV_DOMAIN2@/${pixiivDomain2}/g" /etc/nginx/nginx.conf
sed -i "s/@PXIMG_DOMAIN@/${pximgDomain}/g" /etc/nginx/nginx.conf
sed -i "s/@PXIMG_DOMAIN2@/${pximgDomain2}/g" /etc/nginx/nginx.conf
echo "Done."
echo "Replace the port..."
sed -i "s/@PORT@/${port}/g" /etc/nginx/nginx.conf
echo "Done."
echo "Test nginx config..."
nginx -t
if [ $? = 0 ]
then
    echo "Success!"
else
    echo "Fail!"
    echo "[ERR]Nginx.conf test fail,please check the config!"
    echo -e "Output the nginx.conf...\n\n"
    cat /etc/nginx/nginx.conf
    echo -e "\n\nIs the configuration correct?"
    exit 1
fi
echo -e "Please add the records below to your DNS provider \n"
echo "${pixivDomain}.	1	IN	CNAME	www.${pixivDomain}."
echo "www.${pixivDomain}.	1	IN	CNAME	your.container.domain."
echo "accounts.${pixivDomain}.	1	IN	CNAME	your.container.domain."
echo "source.${pixivDomain}.	1	IN	CNAME	your.container.domain."
echo "imp.${pixivDomain}.	1	IN	CNAME	your.container.domain."
echo "i.${pximgDomain}.	1	IN	CNAME	your.container.domain."
echo "s.${pximgDomain}.	1	IN	CNAME	your.container.domain."
echo -e "pixiv.${pximgDomain}.	1	IN	CNAME	your.container.domain.\n"
echo "Start nginx..."
service nginx start
if [ $? != 0 ]
then
    echo "[ERR]Start nginx failed!"
    echo "[INFO]Please check your setting!"
    exit 1
fi
echo "Done."
echo -e "Start etching nginx access logs...\n"
tail -f -n 20 /var/log/nginx/sccess.log
exit 0