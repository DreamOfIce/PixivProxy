#!/bin/sh
#交互式配置脚本

#function
addConfig() {
    (
        grep -v ${0} ../config
        echo ${0}=${1}
    ) >../config
}

source ../_config

#域名设置
if [ -z "${pixivDomain}" ]; then
    echo "请输入用于反代*.pixiv.net的域名:"
    read pixivDomain
    addConfig 'pixivDomain' $pixivDomain
fi

if [ -z "${pximgDomain}" ]; then
    echo "请输入用于反代.pximg.net的域名:"
    read pximgDomain
    addConfig 'pximgDomain' $pximgDomain
fi

#HTTP设置
if [ -z "${enableHttps}" ]; then
    read -n1 -p "是否要启用HTTPS?[Y/n]" enableHttps
    if [ "${enableHttps,,}" = 'n' ]; then
        addConfig 'enableHttps' 1
    else
        addConfig 'enableHttps' 0
    fi
fi

if [ $enableHttps ]; then
    #邮箱
    read -t30 -p "请输入您的邮箱(您可以使用此邮箱登录ZeroSSL管理证书): " email
    if [ -z "${email}" ]; then
        email="admin@${pixivDomain}"
        echo "使用admin@${pixivDomain}."
    fi
    addConfig 'email' $email

    #DNS授权
    echo '进行DNS授权配置,详细信息 https://github.com/acmesh-official/acme.sh/wiki/dnsapi#2-dnspodcn-option'
    read -p "请输入您的DNS服务商(例如:dns_dp): " dns
    addConfig 'dns' $dns
    echo "请输入设置环境变量代码的base64:"
    read dnsExport
    addConfig 'dnsExport' $dnsExport

    #HTTP端口
    if [ -z $httpPort ]; then
        httpPort=8080
    fi
    read -n5 -p "输入HTTP端口:" httpPort
    if [ -z "${httpPort}" ]; then
        httpPort=80
        echo "使用默认端口:80"
    fi
    addConfig 'httpPort' $httpPort

    #HTTPS端口
    read -t15 -n5 -p "输入HTTPS端口:" httpsPort
    if [ -z "${httpsPort}" ]; then
        httpsPort=443
        echo "使用默认端口:443"
    fi
    addConfig 'httpsPort' $httpsPort
else
    echo "使用HTTP协议."
    if [ -z $httpPort ]; then
        httpPort=8080
    fi
    read -t15 -n5 -p "输入端口:" httpPort
    if [ -z "${httpPort}" ]; then
        httpPort=8080
        echo "使用默认端口:8080"
        fit
        addConfig 'httpPort' $httpPort
    fi
fi

#IP屏蔽
if [-z "${enableGeoIP}" ]; then
    read -n1 -p "是否要屏蔽中国大陆之外的IP[y/N]:" enableGeoIP
    if [ "${enableGeoIP,,}" = "y" ]; then
        read -p "请输入您的GeoIPLite密钥,详见readme:" geoIPKey
        if [ -z "${geoIPKey}" ]; then
            echo "输入为空,跳过GeoIP过滤"
            addConfig 'enableGeoIP' 1
        else
            addConfig 'geoIPKey' $geoIPKey
            addConfig 'enableGeoIP' 0
        fi
    else
        addConfig 'enableGeoIP' 1
    fi
fi
echo '配置完成－O－'
