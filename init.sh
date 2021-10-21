#!/bin/bash
#Init

pixivDomain=$PIXIV_DOMAIN
pximgDomain=$PXIMG_DOMAIN
if [ -z "$pixivDomain" -o -z "$pximgDomain" ]
then
    echo "[ERR]Cannot read the env!Have you set them?"
    echo "[INFO]For more Information,visit https://"
    exit 1
fi
pixivDomain2=${pixivDomain//'.'/'\.'}
pximgDomain2=${pximgDomain//'.'/'\.'}

echo "Pixiv Proxy"
echo "Github: https://github.com/Creeper2077/pixiv-proxy-cn"
echo " Using GPL3.0 License"
echo "Please abide by the use agreement of relevant service providers!"
printf "*.pixiv.net ==> *.%s *.pximg.net ==> *.%s" $pixivDomain $pximgDomain

echo "Replace the domain..."
sed -i 's/@PIXIV_DOMAIN@/${pixivDomain}/g' /etc/nginx/nginx.conf
sed -i 's/@PIXIV_DOMAIN2@/${pixiivDomain2}/g' /etc/nginx/nginx.conf
sed -i 's/@PXIMG_DOMAIN@/${pximgDomain}/g' /etc/nginx/nginx.conf
sed -i 's/@PXIMG_DOMAIN2@/${pximgDomain2}/g' /etc/nginx/nginx.conf
echo "Done."
echo "Start nginx..."
service nginx start
if [ $? != 0 ]
then
    echo "[ERR]Start nginx failed!"
    echo "[INFO]Please check your setting!"
    exit 1
else
        exit 0
fi