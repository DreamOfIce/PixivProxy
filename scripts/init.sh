#!/bin/bash
#初始化

source ../_config
pixivDomainReg='~^([^.]+)\\.'${pixivDomain//'.'/'\\.'}'$'
pximgDomainReg='~^([^.]+)\\.'${pximgDomain//'.'/'\\.'}'$'

echo "开始初始化"
printf "*.pixiv.net ==> *.%s *.pximg.net ==> *.%s\n" $pixivDomain $pximgDomain
echo "复制proxy.conf..."
if [ $enableHttps ]; then
    cp ../proxy-https.conf /etc/nginx/sites-available/proxy.conf
else
    cp ../proxy-http.conf /etc/nginx/sites-available/proxy.conf
fi
echo "完成."
echo "修改配置文件..."
sed -i "s/@PIXIV_DOMAIN@/${pixivDomain}/g" /etc/nginx/sites-available/proxy.conf
sed -i "s/@PIXIV_DOMAIN_REG@/${pixivDomainReg}/g" /etc/nginx/sites-available/proxy.conf
sed -i "s/@PXIMG_DOMAIN@/${pximgDomain}/g" /etc/nginx/sites-available/proxy.conf
sed -i "s/@PXIMG_DOMAIN_REG@/${pximgDomainReg}/g" /etc/nginx/sites-available/proxy.conf
sed -i "s/@HTTP_PORT@/${httpPort}/g" /etc/nginx/sites-available/proxy.conf
sed -i "s/@HTTPS_PORT@/${httpsPort}/g" /etc/nginx/sites-available/proxy.conf
echo "完成."
echo "重新加载Nginx..."
service nginx start
service nginx reload
echo "完成."
if [ $enableHttps ]; then
    echo "配置SSL..."
    ./ssl.sh
    echo '完成'

fi
if [ $enableGeoIP ]; then
    echo "配置GeoIP过滤."
    ./ip.sh
    echo '完成'
fi
echo "初始化完成."
